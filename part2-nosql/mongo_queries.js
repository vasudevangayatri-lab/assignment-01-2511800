// As per 3 sample MongoDB documents 

// OP1: insertMany() — insert all 3 documents from sample_documents.json
//

db.products.insertMany([
    {
        "product_id": "ELEC-101",
        "name": "UltraView 4K Smart TV",
        "category": "Electronics",
        "brand": "Visionary",
        "price": 599.99,
        "specifications": {
            "screen_size": "55 inch",
            "resolution": "3840 x 2160",
            "voltage": "110-240V",
            "refresh_rate": "120Hz"
        },
        "warranty": {
            "duration": "2 years",
            "type": "Manufacturer Limited Warranty",
            "coverage": ["Parts", "Labor", "Panel"]
        },
        "stock_quantity": 45
    },
    {
        "product_id": "CLOTH-202",
        "name": "Classic Fit Denim Jacket",
        "category": "Clothing",
        "brand": "UrbanThreads",
        "price": 85.0,
        "attributes": {
            "material": "98% Cotton, 2% Elastane",
            "style": "Trucker Jacket",
            "care_instructions": "Machine wash cold, tumble dry low"
        },
        "variants": [
            { "size": "S", "color": "Indigo", "sku": "UT-DJ-S-IND" },
            { "size": "M", "color": "Indigo", "sku": "UT-DJ-M-IND" },
            { "size": "L", "color": "Indigo", "sku": "UT-DJ-L-IND" }
        ],
        "tags": ["Spring Collection", "Durable", "Casual"]
    },
    {
        "product_id": "GROC-303",
        "name": "Organic Almond Milk",
        "category": "Groceries",
        "brand": "NaturePurity",
        "price": 4.5,
        "nutritional_info": {
            "serving_size": "240ml",
            "calories": 30,
            "total_fat": "2.5g",
            "sugars": "0g",
            "vitamins": ["Vitamin E", "Vitamin D", "Calcium"]
        },
        "expiry_date": ISODate("2024-12-15T00:00:00Z"),
        "is_refrigerated": true,
        "certifications": ["USDA Organic", "Non-GMO", "Vegan"]
    }
]);

// OP2: find() — retrieve all Electronics products with price > 20000
//
// Note: In the sample data, prices are in lower denominations (e.g., 599.99).
// This query follows the given logic but uses the specific 'Electronics' category.
db.products.find({
    category: "Electronics",
    price: { $gt: 20000 }
});

// OP3: find() — retrieve all Groceries expiring before 2025-01-01
db.products.find({
    category: "Groceries",
    expiry_date: { $lt: ISODate("2025-01-01T00:00:00Z") }
});

// OP4: updateOne() — add a "discount_percent" field to a specific product
db.products.updateOne(
    { product_id: "ELEC-101" },
    { $set: { "discount_percent": 15 } }
);

// OP5: createIndex() — create an index on category field and explain why
db.products.createIndex({ category: 1 });

/* Explanation: Creating an index on 'category' transforms a O(N) collection scan 
into a O(log N) index seek. This is vital for OP2 and OP3 where we filter by 
category; it ensures the database doesn't have to inspect every document 
as the inventory grows.

 O(N) Collection/Table Scan: The database reads every single row in a table or index, 
 making the time cost directly  proportional to the total number of rows.
 O(log N) Index Seek: The database uses a B-tree structure to jump directly to specific rows, 
 skipping irrelevant data, making the time cost proportional to the logarithm of the table size.
*/

/* Implementation Notes

•	Data Consistency: In OP1, I converted the string "2024-12-15" from JSON into a BSON ISODate. 
•	This is mandatory for OP3 to work, as MongoDB cannot perform "less than" date math on raw strings.
•	For OP4, I used product_id instead of name to ensure we target the unique identifier provided in the schema.
*/
