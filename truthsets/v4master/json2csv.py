import csv
import glob
import json
import os


def load_attribute_order():
    """Load and return Senzing attribute configuration ordering."""
    # Load Senzing attribute configuration
    config_path = "/etl/senzing/projects/app/sz_default_config.json"
    with open(config_path, "r", encoding="utf-8") as config_file:
        config = json.load(config_file)

    # Create mapping of attribute codes to their IDs
    attribute_order = {}
    max_attribute_id = 0
    for attr in config["G2_CONFIG"]["CFG_ATTR"]:
        attribute_order[attr["ATTR_CODE"]] = attr["ATTR_ID"]
        max_attribute_id = max(max_attribute_id, attr["ATTR_ID"])

    return attribute_order, max_attribute_id


def get_attribute_id(attr_name, attribute_order, max_attribute_id):
    """Get the attribute ID for a given attribute name, handling prefixes."""
    # Try the full attribute name first
    if attr_name in attribute_order:
        return attribute_order[attr_name]

    # Try without prefix (e.g., "primary_NAME_FIRST" -> "NAME_FIRST")
    parts = attr_name.split("_", 1)
    if len(parts) > 1:
        base_attr = parts[1]
        if base_attr in attribute_order:
            return attribute_order[base_attr]

    # If not found, return a high number to sort to end
    return max_attribute_id + 1


# Specify your input pattern and output file
input_pattern = "/etl/senzing/github/truth-sets/truthsets/v4demo/*.jsonl"  # Change this to your wildcard pattern
output_csv = "/etl/senzing/github/truth-sets/truthsets/v4demo/output.csv"

# Load attribute ordering from config
attr_order, max_attr_id = load_attribute_order()

# Collect all records and unique attribute names
records = []
attribute_names = set()

for filename in glob.glob(input_pattern):
    print(filename)
    with open(filename, "r", encoding="utf-8") as f:
        for line in f:
            record = json.loads(line)
            records.append(record)
            attribute_names.update(record.keys())


# Sort attributes by Senzing ATTR_ID after DATA_SOURCE and RECORD_ID
attribute_names.discard("DATA_SOURCE")
attribute_names.discard("RECORD_ID")
sorted_attributes = sorted(attribute_names, key=lambda x: get_attribute_id(x, attr_order, max_attr_id))
fieldnames = ["DATA_SOURCE", "RECORD_ID"] + sorted_attributes


# Write to CSV
with open(output_csv, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    for record in records:
        writer.writerow({k: record.get(k, "") for k in fieldnames})
