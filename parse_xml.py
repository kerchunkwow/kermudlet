# Assuming you have extracted gizmudlet.xml from the .mpackage file, this script
# will parse it and generate a Lua file; much easier to keep the external Lua in
# synch with the Module scripts when VSCode can interpret the extracted Lua.

import xml.etree.ElementTree as ET

def extract_lua_from_xml(xml_file_path, output_lua_file_path):
    tree = ET.parse(xml_file_path)
    root = tree.getroot()

    strings = {}
    scripts = {}

    # Keeps track of the current element being parsed for name mapping
    current_name = None

    for element in root.iter():
        if element.tag == "name":
            current_name = element.text.strip()
            # Each "name" gets a new list; this has the added benefit of creating empty stubs
            # with the names of Packages/Groups
            strings[current_name] = []
        elif element.tag in ["string", "regex"] and element.text:
            # For elements with multiple strings, append each to a list before inserting into the dict
            strings[current_name].append(element.text.strip())
        elif element.tag == "script" and element.text:
            scripts[current_name] = element.text.strip()

    # utf-8 encoding is necessary here
    with open(output_lua_file_path, "w", encoding='utf-8') as lua_file:
        lua_file.write("extractedStrings = {\n")
        for name, string_list in strings.items():
            combined_strings = ', '.join(f"[[{s}]]" for s in string_list)
            lua_file.write(f"  ['{name}'] = {{{combined_strings}}},\n")
        lua_file.write("}\n\n")

        for name, script in scripts.items():
            lua_file.write(f"-- {name}\n{script}\n\n")

extract_lua_from_xml("./gizmo/gizmudlet.xml", "./gizmo/gizmudlet.lua")
