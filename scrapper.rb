require "http"
require 'net/http'
require "csv"
require 'open-uri'
require 'proxycrawl'
require 'nokogiri'



blankNYCall = "https://api.nytimes.com/svc/books/v3/lists/@@@/combined-print-and-e-book-fiction.json?api-key=mwvIdiGLOAX1GkUfnBbxEXzBZCyaDzsI"
blankAppleCall = "https://uclient-api.itunes.apple.com/WebObjects/MZStorePlatform.woa/wa/lookup?version=2&id=@@@&p=mdm-lockup&caller=MDM&platform=enterprisestore&cc=us&l=en"
api = ProxyCrawl::API.new(token: "p2dKhUnlMZvBIHaVxIovcg")

addedBooksList = File.open("output.csv").read


for year in 2016..2019
    for month in 01..12 do
        puts "#{year}" + "-" + "%02d" % month
        day = 1
        while day< 27
            date = "#{year}" + "-" + "%02d" % month + "-" + "%02d" % day 

            nyCall =  blankNYCall.sub("@@@",date)
            begin
                response = HTTP.get(nyCall)
            failed = 0

            if(response.parse['status'] == "ERROR")
                next
            end

            for bookNum in 0...response.parse['num_results']
    
   
                
            
                # Checks if book was already added  
                if addedBooksList.include?(response.parse['results']['books'][bookNum]['title']) then
                    puts ("Book already added: #{response.parse['results']['books'][bookNum]['title']}\n")
                    next
                end
            
                puts "Checking #{response.parse['results']['books'][bookNum]['title']}"
            
            
                #Gets correct url from Apple Books
                appleURL = response.parse['results']['books'][bookNum]['buy_links'][1]['url']
                newAppleURL = URI.open(appleURL).base_uri
                appleID = newAppleURL.to_s.match(/id(\d+)/)[1]
                appleAPI = blankAppleCall.sub("@@@", appleID)
                responseApple = HTTP.get(appleAPI)
            
            
                #Getting Amazon product information
                url = response.parse['results']['books'][bookNum]['amazon_product_url']
                html = api.get(url)
                doc = Nokogiri::HTML(html.body)
            
            
            
            
                # Checks if the html file includes a physical copy price
                if doc.to_s.include?("priceAmount") then
                    amazonPrice = doc.to_s.match(/"priceAmount":(\d+.\d+)/)[1]
                    amazonAmtRatings = doc.to_s.match(/id="acrCustomerReviewText" class="a-size-base">(\S+)/)[1]
                    amazonRating = doc.to_s.match(/"reviewCountTextLinkedHistogram noUnderline" title="(\S+)/)[1]
            
                # Checks if the html file includes kindle version price
                elsif doc.to_s.include?("displayedPrice") then
                    amazonPrice = doc.to_s.match(/input type="hidden" name="displayedPrice" value="(\d+.\d+)/)[1]
                    amazonAmtRatings = doc.to_s.match(/id="acrCustomerReviewText" class="a-size-base">(\S+)/)[1]
                    amazonRating = doc.to_s.match(/"reviewCountTextLinkedHistogram noUnderline" title="(\S+)/)[1]
            
                # Could not read html file
                else
                    puts "Could not read amazon html"
                    addedBooksList.concat("#{response.parse['results']['books'][bookNum]['title']},")
                    next
                end
            
                
                
             
               
            
                # Checks the link to apple books is invalid, amazon api worked
                if (responseApple.parse['results'] == {}) 
                    puts ("API failed for #{response.parse['results']['books'][bookNum]['title']}")
                    File.open("failedAddings.txt", 'w') { |file| 
                    file.write("API failed for #{response.parse['results']['books'][bookNum]['title']}") }
                    failed =  failed + 1
                
                # Adds book to csv file
                else
                    puts "Adding #{response.parse['results']['books'][bookNum]['title']}"
                    CSV.open("output.csv", "a") do |csv|
                    csv << [response.parse['results']['books'][bookNum]['title'], 
                            response.parse['results']['books'][bookNum]['author'],
                            response.parse['results']['books'][bookNum]['publisher'],
                            response.parse['results']['books'][bookNum]['weeks_on_list'],
                            responseApple.parse['results'][appleID]['ebookInfo']['pageCount'],
                            responseApple.parse['results'][appleID]['genreNames'].first,
                            responseApple.parse['results'][appleID]['userRating']['value'],
                            responseApple.parse['results'][appleID]['userRating']['ratingCount'],
                            responseApple.parse['results'][appleID]['offers'].first['price'],
                            amazonPrice,
                            amazonAmtRatings,
                            amazonRating
            
                        ]
                    end
                    puts("Done adding")
                    # Adds book to added document
                    addedBooksList.concat("#{response.parse['results']['books'][bookNum]['title']},")
                    
                end 
            
                responseApple = nil
            end
            puts("Failed adds: #{failed}")
            



            day = day + 5
            rescue => exception
            day = day + 5 
            end
        end
    end
end






