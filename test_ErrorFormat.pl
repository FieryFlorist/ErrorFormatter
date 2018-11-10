#! /usr/bin/perl
use ErrorFormat;

# Standard Print Mode Tests
print "Simple Test\n";
print printErrFormat(3.5232,0.012) . " =? 3.52(1)\n";
print "Rounding Test\n";
print printErrFormat(3.526,0.012) . " =? 3.53(1)\n";
print "Rounding Test 2\n";
print printErrFormat(3.599,0.012) . " =? 3.60(1)\n";
print "Higher Values\n";
print printErrFormat(35.26124,0.012) . " =? 35.26(1)\n";
print "Higher Errors\n";
print printErrFormat(352.6,23) . " =? 350(20)\n";
print "Smaller Values\n";
print printErrFormat(0.03526,0.00016) . " =? 0.0353(2)\n";
# More Error Than Value Tests
print "More Error Than Value\n";
print printErrFormat(0.0013,12.3) . " =? 0(10)\n";
print "More Error Than Value With Rounding\n";
print printErrFormat(0.567,1.154) . " =? 1(1)\n";
# Weird Rounding Issues

# Scientific Print Mode Tests
print "Big Science Test\n";
print printErrFormat(3506,32) . " =? 3.51(3)E+03\n";
print "Small Science Test\n";
print printErrFormat(0.00003506,0.00000032) . " =? 3.51(3)E-05\n";
print "Big One Digit Test\n";
print printErrFormat(3506,3231) . " =? 4(3)E+03\n";
print "Small One Digit Test\n";
print printErrFormat(0.00003506,0.00003231) . " =? 4(3)E-05\n";
print "Error More Than Value Test\n";
print printErrFormat(123,435251) . " =? 0(4)E+05\n";
print "Error High With Rounding Test\n";
print printErrFormat(723,4351) . " =? 1(4)E+03\n";
