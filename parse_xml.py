# Assuming you have extracted gizmudlet.xml from the .mpackage file, this script
# will parse it and generate a Lua file; much easier to keep the external Lua in
# synch with the Module scripts when VSCode can interpret the extracted Lua.

import xml.etree.ElementTree as ET

# Extract all scripts and pattern strings from a Mudlet module's XML file
def extract_lua_from_xml( input_xml, output_lua ):
    tree = ET.parse( input_xml )
    root = tree.getroot()

    patterns = {}
    scripts  = {}

    # Track the name of the current element being parsed
    current_name = None

    for element in root.iter():
        if element.tag == "name":
            current_name = element.text.strip()
            # Each "name" element gets an entry in the dict; Groups will appear as empty lists
            patterns[current_name] = []
        elif element.tag in ["string", "regex"] and element.text:
            # Elements that have multiple patterns (e.g., multiline triggers) need a list of patterns
            patterns[current_name].append( element.text.strip() )
        elif element.tag == "script" and element.text:
            scripts[current_name] = element.text.strip()

    # Using utf-8, write the parsed content to the specified Lua file
    with open( output_lua, "w", encoding='utf-8' ) as lua_file:
        # Put the patterns in a table
        lua_file.write( "extractedPatterns = {\n" )
        for name, string_list in patterns.items():
            combined_strings = ', '.join( f"[[{s}]]" for s in string_list )
            lua_file.write(f"  ['{name}'] = {{{combined_strings}}},\n")
        lua_file.write("}\n\n")

        # Then dump the scripts; include the name of the source element as a comment
        for name, script in scripts.items():
            lua_file.write(f"-- {name}\n{script}\n\n")

extract_lua_from_xml( "C:/Dev/mud/mudlet/gizmo/gizmudlet.xml", "C:/Dev/mud/mudlet/gizmo/gizmudlet.lua" )
