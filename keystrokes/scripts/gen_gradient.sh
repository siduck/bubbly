#!/bin/dash

red() {
	echo "background-image: radial-gradient( circle farthest-corner at 0.1% 53.8%,  rgba(255,182,172,1) 0%, rgba(255,123,172,1) 100.2% );"
}

lavender() {
	echo "background-image: radial-gradient( circle farthest-corner at 10% 20%,  rgba(186,190,245,1) 0%, rgba(192,192,245,1) 33.1%, rgba(218,203,246,1) 90% );"
}

cutegreen() {
	echo "background-image: radial-gradient( circle 788px at 0.7% 3.4%,  rgba(164,231,192,1) 0%, rgba(255,255,255,1) 90% );"
}

blue() {
	echo "background-image: radial-gradient( circle farthest-corner at 10% 20%,  rgba(97,186,255,1) 0%, rgba(166,239,253,1) 90.1% );"
}

green() {
	echo "background-image: radial-gradient( circle farthest-corner at 10% 20%,  rgba(128,248,174,1) 0%, rgba(223,244,148,1) 90% );"
}

blush() {
	echo "background-image: radial-gradient( circle farthest-corner at 5.3% 17.2%,  rgba(255,208,253,1) 0%, rgba(255,237,216,1) 90% );"
}

"$@"
