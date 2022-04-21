require 'csv'


File.open("addBooks.sql", 'w') { |file| 
    file.write("USE nyt_best_sellers;")}

blankadd = 
"
INSERT IGNORE INTO title(title)
VALUES(%title%);


INSERT IGNORE INTO author(author_name)
VALUES(%author%);


INSERT IGNORE INTO price(Amazon_price, Apple_Books_price)
VALUES(%amazon_price%, %apple_price%);


INSERT IGNORE INTO publisher(publishing_company)
VALUES(%publisher%);


INSERT IGNORE INTO rating(Amazon_rating, Apple_books_rating, Amazon_rating_count, Apple_rating_count)
Values(%amazon_rating%, %apple_rating%, %amazon_count%, %apple_count%);


INSERT IGNORE INTO genres(genre)
VALUES(%genre%);



INSERT INTO books(title_id, author_id, genre_id, price_id, release_date, rating_id, publisher_id, pages)
VALUES((SELECT title_id FROM title WHERE title = %title% LIMIT 1), 
(SELECT author_id FROM author WHERE author_name = %author% LIMIT 1), 
    (SELECT genre_id FROM genres WHERE genre = %genre% LIMIT 1),
    (SELECT price_id FROM price WHERE %amazon_price% = Amazon_price AND %apple_price% = Apple_Books_price LIMIT 1),
    %release_date%, 
    (SELECT rating_id FROM rating WHERE %amazon_rating% = Amazon_rating AND %apple_rating% = Apple_Books_rating AND %amazon_count% = Amazon_rating_count AND %apple_count% = Apple_rating_count LIMIT 1),
    (SELECT publisher_id FROM publisher WHERE publishing_company = %publisher% LIMIT 1),
    %pages%);
"


CSV.foreach("output.csv") do |row|
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
        File.open("addBooks.sql", 'a') { |file| file.write(insertbook)}
end

