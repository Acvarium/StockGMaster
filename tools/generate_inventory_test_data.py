import sqlite3
import random
import string
import argparse
from pathlib import Path

#usage:
#python3 generate_inventory_test_data.py --count 50000 --db "inventory_test.db"


DB_PATH = "test_inventory.db"

def random_text(length=10):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=length))

def create_tables(conn):
    cur = conn.cursor()

    cur.execute('''CREATE TABLE IF NOT EXISTS items (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        description TEXT,
        category_id INT,
        mark INT,
        variant_of_id INT,
        unit_name_id INT,
        image_path TEXT,
        image_rect_id INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS item_stocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        item_id INT,
        location_id INT,
        quantity INT,
        amount REAL,
        mark INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS unit_names (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        parent_id INT,
        description TEXT,
        mark INT,
        is_virtual INT,
        image_path TEXT,
        image_rect_id INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS rect (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        x INT,
        y INT,
        w INT,
        h INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        description TEXT,
        parent_id INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS item_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        item_id INT,
        tag_id INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        description TEXT,
        final_item_id INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS project_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        project_id INT,
        item_id INT,
        quantiry INT,
        amount REAL
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS projeect_build (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        project_id INT,
        quantiry INT,
        location_id INT
    )''')

    cur.execute('''CREATE TABLE IF NOT EXISTS stock_g_master_meta (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        data TEXT
    )''')

    conn.commit()

def insert_seed_data(conn):
    cur = conn.cursor()

    # Unit names
    units = ['pcs', 'kg', 'm', 'box']
    for name in units:
        cur.execute("INSERT INTO unit_names (name) VALUES (?)", (name,))

    # Categories
    for i in range(10):
        cur.execute("INSERT INTO categories (name, description, parent_id) VALUES (?, ?, ?)",
                    (f"Category {i}", f"Desc {i}", None if i == 0 else random.randint(1, i)))

    # Rectangles
    for i in range(10):
        cur.execute("INSERT INTO rect (x, y, w, h) VALUES (?, ?, ?, ?)",
                    (random.randint(0, 100), random.randint(0, 100), 10, 10))

    # Locations
    for i in range(10):
        cur.execute("INSERT INTO locations (name, parent_id, description, mark, is_virtual, image_path, image_rect_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
                    (f"Location {i}", None if i == 0 else random.randint(1, i), f"Loc {i}", 0, 0, "img.png", random.randint(1, 10)))

    conn.commit()

def insert_items(conn, count):
    cur = conn.cursor()
    unit_ids = [row[0] for row in cur.execute("SELECT id FROM unit_names")]
    category_ids = [row[0] for row in cur.execute("SELECT id FROM categories")]
    rect_ids = [row[0] for row in cur.execute("SELECT id FROM rect")]

    for i in range(count):
        name = f"Item {i}"
        desc = f"Description of item {i}"
        category_id = random.choice(category_ids)
        unit_name_id = random.choice(unit_ids)
        rect_id = random.choice(rect_ids)

        cur.execute('''INSERT INTO items (name, description, category_id, mark, variant_of_id,
                        unit_name_id, image_path, image_rect_id)
                       VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
                    (name, desc, category_id, 0, None, unit_name_id, "img.png", rect_id))

        if i % 1000 == 0:
            print(f"Inserted {i} items...")

    conn.commit()
    print(f"Inserted {count} items in total.")

def main():
    parser = argparse.ArgumentParser(description="Generate test inventory database.")
    parser.add_argument("--count", type=int, default=10000, help="Number of items to generate")
    parser.add_argument("--db", type=str, default=DB_PATH, help="Path to SQLite DB file")
    args = parser.parse_args()

    db_path = Path(args.db)
    if db_path.exists():
        print(f"Removing old DB at {db_path}")
        db_path.unlink()

    conn = sqlite3.connect(db_path)
    create_tables(conn)
    insert_seed_data(conn)
    insert_items(conn, args.count)
    conn.close()
    print(f"Database created at {db_path}")

if __name__ == "__main__":
    main()
