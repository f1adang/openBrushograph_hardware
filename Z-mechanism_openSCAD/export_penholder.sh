#!/bin/bash

# Parse available presets from the JSON file (excluding the top-level 'parameterSets' key)
PRESETS=($(grep -E '^[ \t]+"[a-zA-Z0-9_-]+": \{' openBrushograph_Z-mechanism.json | grep -v 'parameterSets' | cut -d'"' -f2))

if [ ${#PRESETS[@]} -eq 0 ]; then
    echo "No presets found in openBrushograph_Z-mechanism.json!"
    exit 1
fi

echo "Please select a Customizer preset to use as the base:"
select PRESET in "${PRESETS[@]}"; do
    if [ -n "$PRESET" ]; then
        break
    else
        echo "Invalid selection."
    fi
done

echo ""
echo "Enter the diameter of the pen holder's hole in mm [Default: 12]:"
read -p "> " DIAM
DIAM=${DIAM:-12}

# Validate diameter input
if [[ ! $DIAM =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Invalid diameter format. Please enter a number."
    exit 1
fi

echo ""
echo "Enter the diameter of the brush insert's hole in mm [Default: 6.5]:"
read -p "> " BRUSH_HOLE
BRUSH_HOLE=${BRUSH_HOLE:-6.5}

# Validate diameter input
if [[ ! $BRUSH_HOLE =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Error: Invalid diameter format. Please enter a number."
    exit 1
fi

echo ""
echo "Exporting pen_holder (${DIAM}mm) and brush_insert (${BRUSH_HOLE}mm) using base preset: $PRESET..."

# Ensure output directory exists
mkdir -p "Z-mechanism_STL/${PRESET}/brushHolder"

PARTS=("pen_holder" "brush_insert")

for PART in "${PARTS[@]}"; do
    if [ "$PART" = "brush_insert" ]; then
        echo "Rendering $PART (Diameter: ${BRUSH_HOLE}mm)..."
        openscad -o "Z-mechanism_STL/${PRESET}/brushHolder/${PRESET}_${PART}_${BRUSH_HOLE}mm_Z-mechanism.stl" \
                 -D "export_part=\"$PART\"" \
                 -D "export_pen_diam=$DIAM" \
                 -D "export_brush_hole=$BRUSH_HOLE" \
                 -p openBrushograph_Z-mechanism.json \
                 -P "$PRESET" \
                 openBrushograph_Z-mechanism.scad
    else
        echo "Rendering $PART (Diameter: ${DIAM}mm)..."
        openscad -o "Z-mechanism_STL/${PRESET}/brushHolder/${PRESET}_${PART}_${DIAM}mm_Z-mechanism.stl" \
                 -D "export_part=\"$PART\"" \
                 -D "export_pen_diam=$DIAM" \
                 -p openBrushograph_Z-mechanism.json \
                 -P "$PRESET" \
                 openBrushograph_Z-mechanism.scad
    fi
done

echo "Pen holder parts successfully exported to the Z-mechanism_STL/${PRESET}/brushHolder/ folder!"
