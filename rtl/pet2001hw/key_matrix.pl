#!/usr/bin/perl
#
# Generate a table that converts PS/2 codes to PET keyboard matrix.
# 

# PS/2 Codes table.  These don't all map to PET keys.
#
@ps2codes = (
#   Code, ASCII, shift ASCII
    0x76, "\033", "\033", # ESC
    0x0e, '`', '~',
    0x16, '1', '!',
    0x1e, '2', '@',
    0x26, '3', '#',
    0x25, '4', '$',
    0x2e, '5', '%',
    0x36, '6', '^',
    0x3d, '7', '&',
    0x3e, '8', '*',
    0x46, '9', '(',
    0x45, '0', ')',
    0x4e, '-', '_',
    0x55, '=', '+',
    0x66, "\b", "\b",	# Backspace
    0x0d, "\t", "\t",	# tab
    0x15, 'q', 'Q',
    0x1d, 'w', 'W',
    0x24, 'e', 'E',
    0x2d, 'r', 'R',
    0x2c, 't', 'T',
    0x35, 'y', 'Y',
    0x3c, 'u', 'U',
    0x43, 'i', 'I',
    0x44, 'o', 'O',
    0x4d, 'p', 'P',
    0x54, '[', '{',
    0x5b, ']', '}',
    0x5d, '\\', '|',
    0x1c, 'a', 'A',
    0x1b, 's', 'S',
    0x23, 'd', 'D',
    0x2b, 'f', 'F',
    0x34, 'g', 'G',
    0x33, 'h', 'H',
    0x3b, 'j', 'J',
    0x42, 'k', 'K',
    0x4b, 'l', 'L',
    0x4c, ';', ':',
    0x52, "\'", "\"",
    0x5a, "\r", "\r",	# Enter
    0x1a, 'z', 'Z',
    0x22, 'x', 'X',
    0x21, 'c', 'C',
    0x2a, 'v', 'V',
    0x32, 'b', 'B',
    0x31, 'n', 'N',
    0x3a, 'm', 'M',
    0x41, ',', '<',
    0x49, '.', '>',
    0x4a, '/', '?',
    0x29, ' ', ' ',	# SPACE

    0x05, "\03", "\03",		# F1 map to STOP (mapped to ctrl-C)
    0x72, "\021", "\021",	# Down Arrow (mapped to ctrl-Q)
    0x74, "\035", "\035",	# Right Arrow (mapped to ctrl-])
    0x6c, "\023", "\023",	# Home (mapped to ctrl-S)
    0x2f, "\022", "\022",	# Apps (mapped to ctrl-R (RVS))

    0x11, "\04", "\04",		# Alt Key (mapped to fake ASCII value)
    0x14, "\05", "\05",		# Ctrl Key (mapped to fake ASCII value)
    );


# (PET) Key matrix --> ASCII (we need to reverse this)
#
@petmatrix = (
# col 7    6     5     4     3     2     1     0 
    0x1d, 0x13, 0x5f, 0x28, 0x26, 0x25, 0x23, 0x21,	# row 0
    0x08, 0x11, 0xff, 0x29, 0x5c, 0x27, 0x24, 0x22,	# row 1
    0x39, 0x37, 0x5e, 0x4f, 0x55, 0x54, 0x45, 0x51,	# row 2
    0x2f, 0x38, 0xff, 0x50, 0x49, 0x59, 0x52, 0x57,	# row 3
    0x36, 0x34, 0xff, 0x4c, 0x4a, 0x47, 0x44, 0x41,	# row 4
    0x2a, 0x35, 0xff, 0x3a, 0x4b, 0x48, 0x46, 0x53,	# row 5
    0x33, 0x31, 0x0d, 0x3b, 0x4d, 0x42, 0x43, 0x5a,	# row 6
    0x2b, 0x32, 0xff, 0x3f, 0x2c, 0x4e, 0x56, 0x58,	# row 7
    0x2d, 0x30, 0xff, 0x3e, 0xff, 0x5d, 0x40, 0x04,	# row 8
    0x3d, 0x2e, 0xff, 0x03, 0x3c, 0x20, 0x5b, 0x12	# row 9
    );

#
# First, create scan-code (and shift) to ASCII...
#
for ($i=0; $i <= $#ps2codes; $i += 3) {
    $code = $ps2codes[ $i ];
    $ascii = ord( $ps2codes[ $i+1 ] );
    $ascii_shift = ord( $ps2codes[ $i+2 ] );

    # printf "  0x%02x 0x%02x 0x%02x\n", $code, $ascii, $ascii_shift;

    if ($scan_to_ascii[ $code ] != 0) {
	printf "scan code used twice!?  code=0x%02x\n", $code;
	die "hmmph.\n";
    }

    $scan_to_ascii[ $code ] = $ascii;
    $scan_shift_to_ascii[ $code ] = $ascii_shift;
}

#
# Next, create ASCII to Commodore keyboard matrix
#
for ($i=0; $i<256; $i++) {
    $ascii_to_pet_row[$i] = -1;
    $ascii_to_pet_col[$i] = -1;
}

for ($i=0; $i <= $#petmatrix ; $i++) {
    $col = 7 - ($i % 8);
    $row = $i / 8;
    $ascii = $petmatrix[$i];

    if ($ascii != 0xff) {
#	printf "row=%d col=%d ascii=0x%02x\n", $row, $col, $ascii;
	$ascii_to_pet_row[ $ascii ] = $row;
	$ascii_to_pet_col[ $ascii ] = $col;
    }
}

#
# Now create function to convert scan codes (including shift) to (x,y)
#
for ($i=0; $i<256; $i++) {
    $ascii = $scan_to_ascii[$i];
    if ($ascii != 0) {
#	printf "scan %02x --> ascii %02x\n", $i, $ascii;

	if ($ascii >= 32) {
	    $keyname = "\'" . pack("c", $ascii) . "\'";
	}
	else {
	    $keyname = sprintf("0x%02x", $ascii);
	}

	if ($ascii >= ord('a') && $ascii <= ord('z')) {
	    $ascii -= 32;  # All upper case!
	}

	$row = $ascii_to_pet_row[ $ascii ];
	$col = $ascii_to_pet_col[ $ascii ];
	if ($row >= 0) {
	    printf "\t\t9'h0_%02X:\tps2_to_pet = 7'h%02X;\t// %s\n",
	    $i, $col * 16 + $row, $keyname;
	}
    }
    $ascii = $scan_shift_to_ascii[$i];
    if ($ascii != 0) {
#	printf "shift scan %02x --> ascii %02x\n", $i, $ascii;

	if ($ascii >= 32) {
	    $keyname = "\'" . pack("c", $ascii) . "\'";
	}
	else {
	    $keyname = sprintf("0x%02x", $ascii);
	}

	$row = $ascii_to_pet_row[ $ascii ];
	$col = $ascii_to_pet_col[ $ascii ];
	if ($row >= 0) {
	    printf "\t\t9'h1_%02X:\tps2_to_pet = 7'h%02X;\t// %s\n",
	    $i, $col * 16 + $row, $keyname;
	}
    }
}
