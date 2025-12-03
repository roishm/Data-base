# Database Documentation - Project Motzklist

This document consolidates the table structure (Schema) and all SQL operations required for development.
The system is built in a hierarchy: **School -> Class -> Equipment**.

---

## Quick Start
Run the ```motzkin-setup.bat```.
Enter your Postgres password, and then you can choose to configure the tables.


## 0. Table Structure (Schema Creation)
The following code generates the necessary tables for the system.
*This must be run once when setting up the environment.*

```sql
-- 1. Schools Table
CREATE TABLE schools (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Classes Table
CREATE TABLE classes (
    id BIGSERIAL PRIMARY KEY,
    school_id BIGINT NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT fk_school
        FOREIGN KEY (school_id)
        REFERENCES schools(id)
        ON DELETE CASCADE
);

-- Index to improve performance when retrieving classes by school
CREATE INDEX idx_classes_school_id ON classes(school_id);

-- 3. Equipment Table
CREATE TABLE equipment (
    id BIGSERIAL PRIMARY KEY,
    class_id BIGINT NOT NULL,
    name TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price DECIMAL(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_class
        FOREIGN KEY (class_id)
        REFERENCES classes(id)
        ON DELETE CASCADE
);

-- Index to improve performance when retrieving equipment by class
CREATE INDEX idx_equipment_class_id ON equipment(class_id);
```
---

## 1. School Management (Schools)

**Note to Developers:** All values marked with `$1`, `$2`, etc. are parameters (Prepared Statements).

### Read
**Get list of all schools** (For main screen / Dropdown)
```sql
SELECT id, name, created_at
FROM schools
ORDER BY name ASC;
```

**Get single school details by ID**
```sql
SELECT * FROM schools WHERE id = $1;
```

### Create
**Add a new school**
Returns the created ID.
```sql
INSERT INTO schools (name)
VALUES ($1)
RETURNING id;
```

### Update
**Change school name**
```sql
UPDATE schools
SET name = $2
WHERE id = $1;
```

### Delete
**Delete school**
*Note:* This action will automatically delete **all** classes and equipment belonging to this school.
```sql
DELETE FROM schools WHERE id = $1;
```

---

## 2. Class Management (Classes)

### Read
**Get list of classes for a specific school**
```sql
SELECT id, name, created_at
FROM classes
WHERE school_id = $1
ORDER BY name ASC;
```

### Create
**Add a class to a school**
Requires providing the School ID ($1) and the Class Name ($2).
```sql
INSERT INTO classes (school_id, name)
VALUES ($1, $2)
RETURNING id;
```

### Update
**Change class name**
```sql
UPDATE classes
SET name = $2
WHERE id = $1;
```

### Delete
**Delete class**
*Note:* This action will automatically delete the **entire** equipment list of the class.
```sql
DELETE FROM classes WHERE id = $1;
```

---

## 3. Equipment Management (Equipment)

### Read
**Get full equipment list for a class**
Includes calculation of total row price (quantity * unit price).
```sql
SELECT 
    id, 
    name, 
    quantity, 
    price, 
    (quantity * price) as total_row_price
FROM equipment
WHERE class_id = $1
ORDER BY name ASC;
```

### Create
**Add item to equipment list**
Parameters: Class ID ($1), Item Name ($2), Quantity ($3), Price ($4).
```sql
INSERT INTO equipment (class_id, name, quantity, price)
VALUES ($1, $2, $3, $4)
RETURNING id;
```

### Update
**Update existing equipment item**
Allows updating the name, quantity, and price at once.
```sql
UPDATE equipment
SET name = $2, quantity = $3, price = $4
WHERE id = $1;
```

### Delete
**Delete specific equipment item from the list**
```sql
DELETE FROM equipment WHERE id = $1;
```

---

## 4. Reports and Advanced Queries (Analytics)

### Global Equipment Search
"Who uses the Benny Goren math book?" - Returns all classes and schools that have an item containing the search string.
```sql
SELECT 
    s.name as school_name,
    c.name as class_name,
    e.name as item_name,
    e.quantity
FROM equipment e
JOIN classes c ON e.class_id = c.id
JOIN schools s ON c.school_id = s.id
WHERE e.name ILIKE '%' || $1 || '%' -- $1 is the search term
ORDER BY s.name, c.name;
```

### School Cost Report (Budget)
Calculates the cost to equip the entire school (sum of all equipment in all classes).
```sql
SELECT 
    s.name as school_name,
    COUNT(DISTINCT c.id) as total_classes,
    COALESCE(SUM(e.quantity * e.price), 0) as total_budget_needed
FROM schools s
LEFT JOIN classes c ON s.id = c.school_id
LEFT JOIN equipment e ON c.id = e.class_id
WHERE s.id = $1
GROUP BY s.id, s.name;
```

### "Empty Classes" Report
Finding classes that have no equipment entered yet (important for auditing).
```sql
SELECT 
    s.name as school_name,
    c.name as class_name
FROM classes c
JOIN schools s ON c.school_id = s.id
LEFT JOIN equipment e ON c.id = e.class_id
WHERE e.id IS NULL
ORDER BY s.name;
```