require 'csv'


File.open("addBooks2.sql", 'w') { |file| 
    file.write("USE nyt_best_sellers;")}

blankadd = 
"
INSERT IGNORE INTO author(author_name)
VALUES(%author%);

INSERT IGNORE INTO publisher(publishing_company)
VALUES(%publisher%);

INSERT IGNORE INTO AmazonRating(Amazon_rating)
Values(%amazon_rating%);

INSERT IGNORE INTO AppleRating(Apple_rating)
Values(%apple_rating% );

INSERT IGNORE INTO genres(genre)
VALUES(%genre%);

INSERT IGNORE INTO AmazonPrice(Amazon_Price)
Values(%amazon_price%);

INSERT IGNORE INTO ApplePrice(Apple_Price)
Values(%apple_price%);




INSERT IGNORE INTO books(Title, author_id, genre_id, release_date, pages, publisher_id, Apple_Ratings_Count, Amazon_Ratings_Count, AppleRating_id, AmazonRating_id, AmazonPrice_id, ApplePrice_id)
VALUES(%title%, 
	(SELECT author_id FROM author WHERE author_name = %author%), 
    (SELECT genre_id FROM genres WHERE genre = %genre%),
    %release_date%, 
    %pages%,
    (SELECT publisher_id FROM publisher WHERE publishing_company = %publisher%),
    %apple_count%,
    %amazon_count%,
    (SELECT AppleRating_id FROM AppleRating WHERE Apple_rating = %apple_rating%),
    (SELECT AmazonRating_id FROM AmazonRating WHERE Amazon_rating = %amazon_rating%),
    (SELECT ApplePrice_id FROM ApplePrice WHERE Apple_price = %apple_price%),
    (SELECT AmazonPrice_id FROM AmazonPrice WHERE Amazon_price = %amazon_price%)
);


INSERT IGNORE INTO AllRatings(book_id, AmazonRating_id, AppleRating_id, AverageRating)
VALUES(
	(SELECT book_id FROM books WHERE Title = %title% AND pages = %pages%),
	(SELECT AppleRating_id FROM AppleRating WHERE Apple_rating = %apple_rating%),
    (SELECT AmazonRating_id FROM AmazonRating WHERE Amazon_rating = %amazon_rating%),
    %avg_rating%);
    
INSERT IGNORE INTO AllPrices(book_id, AmazonPrice_id, ApplePrice_id, AveragePrice)
VALUES(
	(SELECT book_id FROM books WHERE Title = %title% AND pages = %pages%),
	(SELECT ApplePrice_id FROM ApplePrice WHERE Apple_price = %apple_price%),
    (SELECT AmazonPrice_id FROM AmazonPrice WHERE Amazon_price = %amazon_price%),
    %avg_price%);
"


CSV.foreach("output.csv") do |row|
    avgrating = ((row[6].to_f) + (row[11].to_f))/2
    avgprice = (row[8].to_f + row[9].to_f)/2
    insertbook = blankadd.gsub("%title%", "\"#{row[0]}\"")
                         .gsub("%author%", "\"#{row[1]}\"")
                         .gsub("%publisher%", "\"#{row[2]}\"")
                         .gsub("%pages%", row[4])
                         .gsub("%genre%", "\"#{row[5]}\"")
                         .gsub("%apple_rating%", (row[6].to_f).to_s)
                         .gsub("%apple_count%", row[7].to_s.sub(",",""))
                         .gsub("%apple_price%", row[8])
                         .gsub("%amazon_price%", row[9])
                         .gsub("%amazon_count%", row[10].to_s.sub(",",""))
                         .gsub("%amazon_rating%", (row[11].to_f).to_s)
                         .gsub("%release_date%", "\'#{(Date.today-rand(10000)).to_s}\'")
                         .gsub("%avg_rating%", avgrating.round(2).to_s)
                         .gsub("%avg_price%", avgprice.round(2).to_s)
        File.open("addBooks2.sql", 'a') { |file| file.write(insertbook)}
end

