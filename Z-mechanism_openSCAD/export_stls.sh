#!/bin/bash

# Parse available presets from the JSON file (excluding the top-level 'parameterSets' key)
PRESETS=($(grep -E '^[ \t]+"[a-zA-Z0-9_-]+": \{' openBrushograph_Z-mechanism.json | grep -v 'parameterSets' | cut -d'"' -f2))

if [ ${#PRESETS[@]} -eq 0 ]; then
    echo "No presets found in openBrushograph_Z-mechanism.json!"
    exit 1
fi

echo "Please select a Customizer preset to export:"
select PRESET in "${PRESETS[@]}"; do
    if [ -n "$PRESET" ]; then
        break
    else
        echo "Invalid selection."
    fi
done

echo ""
echo "Exporting core Z-mechanism parts using preset: $PRESET"

# Ensure output directory exists
mkdir -p "Z-mechanism_STL/${PRESET}"

# Only render the core hardware parts
PARTS=("rail" "gearwheel" "rackpen")

for PART in "${PARTS[@]}"; do
    echo "Rendering $PART..."
    openscad -o "Z-mechanism_STL/${PRESET}/${PRESET}_${PART}_Z-mechanism.stl" \
             -D "export_part=\"$PART\"" \
             -p openBrushograph_Z-mechanism.json \
             -P "$PRESET" \
             openBrushograph_Z-mechanism.scad
done

echo "Core parts successfully exported to the Z-mechanism_STL/${PRESET} folder!"
