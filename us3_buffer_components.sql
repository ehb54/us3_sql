--
-- us3_bufferComponent_data.sql
--
-- ported from US3 buffer component data
--
DELETE FROM bufferComponent;

INSERT INTO bufferComponent SET
 bufferComponentID =   1,
 units             = 'mM',
 description       = '1-Propanol',
 viscosity         = '1.007250 -119.106220 44.352310 7.820880 -31.162010 0.000000',
 density           = '0.998200 0.000000 -1.212450 2.810440 -7.631480 53.397170',
 c_range           = '0-6.741 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   2,
 units             = 'mM',
 description       = '2-Propanol',
 viscosity         = '1.000470 0.000000 31.732830 26.300370 88.915350 0.000000',
 density           = '0.999300 -12.146050 0.161920 -1.419550 0.231100 0.000000',
 c_range           = '0-13.06 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   3,
 units             = 'mM',
 description       = 'Acetic acid',
 viscosity         = '0.999970 1.785270 11.716390 2.375000 -0.972840 0.000000',
 density           = '0.998250 -0.302260 0.888900 -0.280980 0.086070 -0.573000',
 c_range           = '0-14.277 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   4,
 units             = 'mM',
 description       = 'Acetone',
 viscosity         = '1.018320 -95.420000 25.016000 -31.730000 30.000000 0.000000',
 density           = '0.997970 1.142000 -0.944450 -0.028650 6.564500 -201.130010',
 c_range           = '0-1.697 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   5,
 units             = 'mM',
 description       = 'Ammonium Acetate',
 viscosity         = '1.001420 265.450000 -6.225000 37.270000 0.000000 0.000000',
 density           = '0.998220 18.050000 0.437000 2.450000 0.000000 0.000000',
 c_range           = '0-1 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   6,
 units             = 'mM',
 description       = 'Ammonium chloride',
 viscosity         = '1.000020 -4.070820 -2.045080 3.321660 2.228520 0.000000',
 density           = '0.998240 -0.189820 1.738730 -0.923860 1.038060 -7.398990',
 c_range           = '0-4.788 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   7,
 units             = 'mM',
 description       = 'Ammonium hydroxide',
 viscosity         = '1.000340 0.000000 2.175440 0.963440 -0.760540 0.000000',
 density           = '0.998230 0.000000 -0.756260 0.056450 0.005660 -0.057820',
 c_range           = '0-13.802 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   8,
 units             = 'mM',
 description       = 'Ammonium sulfate',
 viscosity         = '0.998640 0.000000 17.777110 25.798420 100.050500 0.000000',
 density           = '0.998220 0.000000 7.871960 -6.463300 6.192840 -29.249050',
 c_range           = '0-3.716 M';

INSERT INTO bufferComponent SET
 bufferComponentID =   9,
 units             = 'mM',
 description       = 'Barium chloride',
 viscosity         = '1.000310 14.910000 19.463000 43.900000 143.000000 0.000000',
 density           = '0.998210 0.504140 17.996000 -3.426900 12.895000 -531.229980',
 c_range           = '0-1.6 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  10,
 units             = 'mM',
 description       = 'Cadmium chloride',
 viscosity         = '1.000540 0.000000 24.130670 52.147750 230.585010 0.000000',
 density           = '0.998370 -5.107260 16.269250 -4.817770 7.092190 -50.019970',
 c_range           = '0-5.539 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  11,
 units             = 'mM',
 description       = 'Cadmium sulfate',
 viscosity         = '1.005310 -112.336360 84.958750 -61.848510 1700.261960 0.000000',
 density           = '0.997940 7.860840 17.756440 16.418380 -108.493910 1884.344970',
 c_range           = '0-2.966 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  12,
 units             = 'mM',
 description       = 'Calcium chloride',
 viscosity         = '1.001190 -32.316000 34.639140 -26.747700 373.854000 0.000000',
 density           = '0.998160 1.675250 8.789410 -2.375310 1.318310 -7.868430',
 c_range           = '0-5.03 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  13,
 units             = 'mM',
 description       = 'Cesium chloride',
 viscosity         = '1.001160 -19.410400 -4.078630 11.548900 -21.774000 0.000000',
 density           = '0.998240 0.000000 12.686410 1.274450 -11.954000 258.866000',
 c_range           = '0-1.916 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  14,
 units             = 'mM',
 description       = 'Citric acid',
 viscosity         = '0.999720 0.000000 43.297390 104.858980 811.618650 0.000000',
 density           = '0.998170 0.000000 7.844030 -1.869400 14.693120 -496.345370',
 c_range           = '0-1.772 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  15,
 units             = 'mM',
 description       = 'Cobaltous chloride',
 viscosity         = '0.992000 71.010000 26.938000 116.010000 91.000000 0.000000',
 density           = '0.997980 1.471000 11.409000 -2.916500 12.496000 -0.039390',
 c_range           = '0-1.856 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  16,
 units             = 'mM',
 description       = 'Creatinine',
 viscosity         = '1.001500 -7.780000 19.066000 411.540010 -4066.800050 0.000000',
 density           = '0.999080 -6.551100 4.182400 -21.007000 252.350010 -10365.000000',
 c_range           = '0-721 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  17,
 units             = 'mM',
 description       = 'Cupric sulfate',
 viscosity         = '1.021330 -193.070010 100.420000 -258.329990 3007.000000 0.000000',
 density           = '0.998270 -0.641840 16.592000 -14.691000 33.735000 0.041690',
 c_range           = '0-1.36 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  18,
 units             = 'mM',
 description       = 'EDTA disodium',
 viscosity         = '1.000130 0.000000 98.510000 0.000000 21831.000000 0.000000',
 density           = '0.998240 0.000000 17.825580 -16.334590 0.000000 0.000000',
 c_range           = '0-184 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  19,
 units             = 'mM',
 description       = 'Ethanol',
 viscosity         = '0.994910 77.682700 7.861540 62.888750 -61.693170 0.000000',
 density           = '0.998180 0.731330 -1.014060 1.269630 -1.680560 5.427400',
 c_range           = '0-8.853 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  20,
 units             = 'mM',
 description       = 'Ethylene glycol',
 viscosity         = '1.026500 -115.810000 24.791000 -4.443600 20.079000 0.000000',
 density           = '0.998220 0.061850 0.749080 0.146330 -0.151390 0.116260',
 c_range           = '0-10.406 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  21,
 units             = 'mM',
 description       = 'Ferric chloride',
 viscosity         = '1.113730 -705.030030 171.625000 -410.679990 2078.100100 0.000000',
 density           = '0.999000 -3.320500 13.930000 -11.115000 27.991000 -307.160000',
 c_range           = '0-3.496 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  22,
 units             = 'mM',
 description       = 'Formic acid',
 viscosity         = '0.997870 10.300000 2.617000 -0.667070 0.391380 0.000000',
 density           = '0.998730 -1.811600 1.235000 -0.213540 0.003090 0.153300',
 c_range           = '0-17.62 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  23,
 units             = 'mM',
 description       = 'Fructose',
 viscosity         = '1.000380 0.000000 43.670900 104.027000 916.479000 0.000000',
 density           = '0.998220 0.000000 7.047410 -0.923560 0.691110 -8.972270',
 c_range           = '0-5.223 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  24,
 units             = 'mM',
 description       = 'Glucose',
 viscosity         = '1.000140 -67.698000 65.237000 -115.747000 2080.655030 0.000000',
 density           = '0.998210 0.000000 6.820080 0.197040 -4.138210 57.378800',
 c_range           = '0-4.261 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  25,
 units             = 'mM',
 description       = 'Glycerol%',
 viscosity         = '1.001800 -8.247600 2.673000 0.310900 0.114300 0.122300',
 density           = '0.998230 0.030860 0.224900 0.006330 0.000030 0.000040',
 c_range           = '0-32 %weight/weight';

INSERT INTO bufferComponent SET
 bufferComponentID =  26,
 units             = 'mM',
 description       = 'Glycerol',
 viscosity         = '1.001760 -37.580400 27.137880 7.643330 112.082600 0.000000',
 density           = '0.998240 0.000000 2.082350 0.141720 -0.264530 0.540730',
 c_range           = '0-13.694 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  27,
 units             = 'mM',
 description       = 'Guanidine hydrochloride',
 viscosity         = '1.000530 -47.789510 9.784620 -13.520250 29.722420 0.000000',
 density           = '0.998230 0.000000 2.588700 -0.366840 0.101320 -0.204550',
 c_range           = '0-7.355 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  28,
 units             = 'mM',
 description       = 'Hydrochloric acid',
 viscosity         = '1.000610 -10.084110 6.045430 -0.357690 2.071530 0.000000',
 density           = '0.998240 0.000000 1.790770 -0.295170 0.168450 -0.771710',
 c_range           = '0-13.137 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  29,
 units             = 'mM',
 description       = 'Inulin',
 viscosity         = '1.010570 0.000000 2177.989990 841199.000000 0.000000 0.000000',
 density           = '0.998670 -25.843000 208.552310 0.000000 0.000000 0.000000',
 c_range           = '0-20 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  30,
 units             = 'mM',
 description       = 'Lactic acid',
 viscosity         = '1.004820 -26.280000 26.375000 7.460000 62.100000 0.000000',
 density           = '0.999400 -5.901800 2.465400 -0.790000 0.458950 -1.701300',
 c_range           = '0-10.523 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  31,
 units             = 'mM',
 description       = 'Lactose',
 viscosity         = '0.987150 120.600000 56.536000 1613.849980 -2643.199950 0.000000',
 density           = '0.998540 -3.993300 14.402000 15.795000 -1454.400020 185350.000000',
 c_range           = '0-565 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  32,
 units             = 'mM',
 description       = 'Lanthanum nitrate',
 viscosity         = '1.069220 -503.820010 133.437000 -586.229980 4068.699950 0.000000',
 density           = '1.002300 -31.909000 31.955000 -50.500000 200.020000 -3482.800050',
 c_range           = '0-2.043 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  33,
 units             = 'mM',
 description       = 'Lead nitrate',
 viscosity         = '1.008270 -61.350000 26.067000 25.090000 331.399990 0.000000',
 density           = '0.998480 -1.475000 28.361000 -0.334090 -35.333000 694.370000',
 c_range           = '0-1.432 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  34,
 units             = 'mM',
 description       = 'Lithium chloride',
 viscosity         = '1.063310 -225.640000 33.701000 -33.170000 49.200000 0.000000',
 density           = '0.998200 0.324100 2.447400 -0.754250 0.698940 -2.540600',
 c_range           = '0-8.343 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  35,
 units             = 'mM',
 description       = 'Magnesium chloride',
 viscosity         = '0.999700 7.406280 39.496000 35.391410 441.971990 0.000000',
 density           = '0.998340 -2.525530 8.099050 -4.671380 7.169410 -51.732900',
 c_range           = '0-4.021 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  36,
 units             = 'mM',
 description       = 'Magnesium sulfate',
 viscosity         = '1.070970 -541.450010 162.022000 -623.450010 3770.699950 0.000000',
 density           = '0.997570 4.305700 11.488000 -4.451800 1.444700 0.239600',
 c_range           = '0-2.799 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  37,
 units             = 'mM',
 description       = 'Maltose',
 viscosity         = '1.024900 -277.989990 169.590000 -692.770020 16953.000000 0.000000',
 density           = '0.996260 17.535000 10.052000 23.283000 -108.960000 1730.800050',
 c_range           = '0-2.252 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  38,
 units             = 'mM',
 description       = 'Manganous sulfate',
 viscosity         = '0.955460 291.750000 13.355000 534.929990 -15.355000 0.000000',
 density           = '0.997380 5.922400 13.516000 2.652000 -38.660000 930.130000',
 c_range           = '0-1.616 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  39,
 units             = 'mM',
 description       = 'Mannitol',
 viscosity         = '0.999450 51.509600 31.610800 480.648010 -1093.276370 0.000000',
 density           = '0.998250 -0.781600 6.706350 -10.135400 74.047500 0.000000',
 c_range           = '0-867 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  40,
 units             = 'mM',
 description       = 'Methanol',
 viscosity         = '1.001620 0.000000 10.359880 1.428090 -3.454300 0.000000',
 density           = '0.998190 0.339980 -0.616220 0.230910 -0.177440 0.212600',
 c_range           = '0-19.901 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  41,
 units             = 'mM',
 description       = 'Nickel sulfate',
 viscosity         = '0.996670 50.520000 49.387000 542.370000 -2099.100100 0.000000',
 density           = '0.994630 40.585000 3.822900 405.579990 -9318.799810 791150.000000',
 c_range           = '0-412 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  42,
 units             = 'mM',
 description       = 'Nitric acid',
 viscosity         = '0.998470 8.530000 0.430000 9.320000 -1.659080 0.000000',
 density           = '0.998120 0.517710 3.358300 -0.262510 0.181500 -2.871000',
 c_range           = '0-7.913 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  43,
 units             = 'mM',
 description       = 'Oxalic acid',
 viscosity         = '1.003790 -22.490000 22.548000 -37.030000 148.600010 0.000000',
 density           = '0.995500 17.697000 0.987540 45.770000 -509.549990 20740.000000',
 c_range           = '0-920 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  44,
 units             = 'mM',
 description       = 'Phosphoric acid',
 viscosity         = '0.999440 -18.230400 26.885000 21.887700 70.354500 0.000000',
 density           = '0.998150 2.349590 4.851080 0.475530 -0.788610 0.000000',
 c_range           = '0-5.117 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  45,
 units             = 'mM',
 description       = 'Potassium bicarbonate',
 viscosity         = '0.999950 8.596650 10.171040 22.781890 7.243690 0.000000',
 density           = '0.998150 0.000000 6.622330 -4.522630 14.213060 -177.000000',
 c_range           = '0-2.801 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  46,
 units             = 'mM',
 description       = 'Potassium biphthalate',
 viscosity         = '1.004330 -30.570000 51.722000 -13.780000 1660.000000 0.000000',
 density           = '0.998380 0.708210 7.731900 87.984000 -2443.500000 224850.000000',
 c_range           = '0-405 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  47,
 units             = 'mM',
 description       = 'Potassium bromide',
 viscosity         = '1.002150 -7.990000 -4.490000 9.550000 2.696680 0.000000',
 density           = '0.998150 0.464470 8.454300 -1.263400 2.018100 -17.792000',
 c_range           = '0-4.62 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  48,
 units             = 'mM',
 description       = 'Potassium carbonate',
 viscosity         = '1.005020 -27.950000 34.010000 5.110000 262.700010 0.000000',
 density           = '0.997320 5.952300 11.484000 -4.754100 2.033800 1.606700',
 c_range           = '0-5.573 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  49,
 units             = 'mM',
 description       = 'Potassium chloride',
 viscosity         = '1.000430 0.000000 -1.472760 2.984520 9.715300 0.000000',
 density           = '0.998230 0.000000 4.751620 -1.649230 2.564320 -20.900000',
 c_range           = '0-3.742 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  50,
 units             = 'mM',
 description       = 'Potassium chromate',
 viscosity         = '0.996310 31.420000 10.300000 58.630000 27.000000 0.000000',
 density           = '0.997880 3.905300 14.644000 -3.224400 32.244000 -804.169980',
 c_range           = '0-1.972 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  51,
 units             = 'mM',
 description       = 'Potassium dichromate',
 viscosity         = '0.999900 0.000000 2.891290 0.000000 0.000000 0.000000',
 density           = '0.998270 0.000000 20.353010 -15.298530 0.000000 0.000000',
 c_range           = '0-364 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  52,
 units             = 'mM',
 description       = 'Potassium ferricyanide',
 viscosity         = '1.000320 20.960000 6.650000 155.570010 607.400020 0.000000',
 density           = '0.998190 0.814860 16.814000 7.081400 -48.194000 -3250.300050',
 c_range           = '0-1.073 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  53,
 units             = 'mM',
 description       = 'Potassium ferrocyanide',
 viscosity         = '0.998350 47.920000 26.180000 321.500000 -37.600000 0.000000',
 density           = '0.997190 13.366000 20.211000 65.135000 -1361.300050 93298.000000',
 c_range           = '0-618 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  54,
 units             = 'mM',
 description       = 'Potassium hydroxide',
 viscosity         = '1.000110 -11.470670 11.748420 1.713390 15.481950 0.000000',
 density           = '0.998380 -1.503660 4.989640 -1.654900 0.848640 -2.037800',
 c_range           = '0-13.388 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  55,
 units             = 'mM',
 description       = 'Potassium iodide',
 viscosity         = '0.993610 46.490000 -16.971000 62.240000 -92.800000 0.000000',
 density           = '0.998090 1.076200 11.986000 -1.250600 3.234200 -42.415000',
 c_range           = '0-3.363 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  56,
 units             = 'mM',
 description       = 'Potassium nitrate',
 viscosity         = '1.000530 -6.640000 -4.834000 25.160000 -18.800000 0.000000',
 density           = '0.998750 -2.890000 6.724700 -4.726900 13.787000 -174.780000',
 c_range           = '0-2.759 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  57,
 units             = 'mM',
 description       = 'Potassium oxalate',
 viscosity         = '1.006820 -64.490000 31.846000 -91.680000 905.700010 0.000000',
 density           = '0.998920 -5.691400 13.027000 -22.574000 185.270000 -5858.299800',
 c_range           = '0-931 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  58,
 units             = 'mM',
 description       = 'Potassium permanganate',
 viscosity         = '0.996270 37.230000 -13.001000 201.770000 -2747.000000 0.000000',
 density           = '0.997570 7.944500 8.248000 73.895000 -2002.300050 196460.000000',
 c_range           = '0-394 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  59,
 units             = 'mM',
 description       = 'Potassium phosphate, di-basic',
 viscosity         = '0.999920 -6.685980 39.158590 0.000000 1650.510010 0.000000',
 density           = '0.998260 0.000000 14.745890 -16.328000 112.098000 0.000000',
 c_range           = '0-491 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  60,
 units             = 'mM',
 description       = 'Potassium phosphate, mono-basic',
 viscosity         = '1.000220 -14.152200 26.391160 112.626500 -458.141600 0.000000',
 density           = '0.998250 0.000000 9.523950 5.560570 -252.160000 15765.000000',
 c_range           = '0-786 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  61,
 units             = 'mM',
 description       = 'Potassium sulfate',
 viscosity         = '0.999850 0.000000 14.832490 170.834180 -1156.524170 0.000000',
 density           = '0.998230 -1.000360 14.289010 -19.070380 78.097650 0.000000',
 c_range           = '0-620 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  62,
 units             = 'mM',
 description       = 'Potassium thiocyanate',
 viscosity         = '1.003070 -12.380000 -4.647000 15.220000 1.774650 0.000000',
 density           = '0.997780 2.722840 4.411850 0.000000 -0.597690 3.203630',
 c_range           = '0-9.123 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  63,
 units             = 'mM',
 description       = 'Procaine hydrochloride',
 viscosity         = '1.134440 -1106.500000 287.845000 -1966.530030 13734.200190 0.000000',
 density           = '0.998270 -0.051650 4.521600 4.967600 -27.695000 469.019990',
 c_range           = '0-2.453 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  64,
 units             = 'mM',
 description       = 'Propylene glycol',
 viscosity         = '1.007730 -331.179990 56.205000 -24.690000 112.700000 0.000000',
 density           = '0.997940 1.268500 0.293840 1.499600 -2.581400 12.722000',
 c_range           = '0-8.215 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  65,
 units             = 'mM',
 description       = 'Silver nitrate',
 viscosity         = '0.997890 13.770000 3.314000 19.130000 -1.523080 0.000000',
 density           = '0.998410 1.192300 13.843000 0.788210 -8.464500 131.369990',
 c_range           = '0-3.471 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  66,
 units             = 'mM',
 description       = 'Sodium acetate',
 viscosity         = '1.001770 -30.892770 35.991200 44.794180 144.796010 0.000000',
 density           = '0.998090 4.174940 3.225950 5.428050 -18.293600 180.915760',
 c_range           = '0-4.243 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  67,
 units             = 'mM',
 description       = 'Sodium bicarbonate',
 viscosity         = '0.999680 0.000000 21.850000 38.650000 0.000000 0.000000',
 density           = '0.998230 0.000000 5.968170 0.000000 -114.941600 9653.325190',
 c_range           = '0-743 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  68,
 units             = 'mM',
 description       = 'Sodium bromide',
 viscosity         = '1.002060 -7.130000 5.337000 4.870000 26.400000 0.000000',
 density           = '0.998060 0.952500 7.820800 -0.776710 0.491680 -1.047700',
 c_range           = '0-5.495 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  69,
 units             = 'mM',
 description       = 'Sodium carbonate',
 viscosity         = '0.988370 58.180000 42.146000 157.310000 851.400020 0.000000',
 density           = '0.998190 0.215010 11.026000 -13.477000 47.431000 -885.000000',
 c_range           = '0-1.638 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  70,
 units             = 'mM',
 description       = 'Sodium chloride',
 viscosity         = '1.001930 -5.059870 9.638620 0.000000 31.658300 0.000000',
 density           = '0.998230 0.000000 4.147120 -1.239750 1.155280 -5.214150',
 c_range           = '0-5.326 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  71,
 units             = 'mM',
 description       = 'Sodium citrate',
 viscosity         = '0.999690 0.000000 99.984320 93.873500 8944.839840 0.000000',
 density           = '0.998300 -4.205530 18.788490 -16.483280 0.000000 763.068420',
 c_range           = '0-1.792 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  72,
 units             = 'mM',
 description       = 'Sodium diatrizoate',
 viscosity         = '1.168720 -1681.930050 539.869020 -5855.609860 74457.500000 0.000000',
 density           = '1.002000 -44.591000 50.903000 -247.360000 3568.100100 -190300.000000',
 c_range           = '0-836 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  73,
 units             = 'mM',
 description       = 'Sodium dichromate',
 viscosity         = '1.001770 -9.250000 21.660000 36.370000 672.799990 0.000000',
 density           = '0.998520 -0.806760 19.020000 -5.900600 9.352900 -76.756000',
 c_range           = '0-3.839 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  74,
 units             = 'mM',
 description       = 'Sodium ferrocyanide',
 viscosity         = '0.989470 134.910000 53.094000 797.609990 4226.500000 0.000000',
 density           = '0.998530 -4.003200 23.688000 -109.190000 2240.100100 -173750.000000',
 c_range           = '0-550 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  75,
 units             = 'mM',
 description       = 'Sodium hydroxide',
 viscosity         = '1.000710 -27.641130 25.331240 -1.804660 109.270000 0.000000',
 density           = '0.998160 1.542030 4.275330 -1.521000 0.695300 -1.904400',
 c_range           = '0-14.295 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  76,
 units             = 'mM',
 description       = 'Sodium molybdate',
 viscosity         = '0.996610 50.810000 34.146000 268.519990 -430.799990 0.000000',
 density           = '0.998080 3.104000 15.805000 86.447000 -2259.300050 183100.000000',
 c_range           = '0-472 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  77,
 units             = 'mM',
 description       = 'Sodium phosphate, di-basic',
 viscosity         = '1.000150 -26.943140 66.223440 0.000000 4665.331050 0.000000',
 density           = '0.998260 0.000000 14.158260 -28.770170 234.237400 0.000000',
 c_range           = '0-408 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  78,
 units             = 'mM',
 description       = 'Sodium phosphate, mono-basic',
 viscosity         = '0.998980 0.000000 38.409330 60.612700 433.133000 0.000000',
 density           = '0.998260 0.000000 8.835060 -3.857940 5.298880 -40.556640',
 c_range           = '0-4.499 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  79,
 units             = 'mM',
 description       = 'Sodium phosphate, tri-basic',
 viscosity         = '0.999880 49.429150 72.278510 1062.909060 0.000000 0.000000',
 density           = '0.998230 2.357600 18.001870 6.891820 -136.311000 0.000000',
 c_range           = '0-535 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  80,
 units             = 'mM',
 description       = 'Sodium sulfate',
 viscosity         = '0.996940 0.000000 40.406900 85.319600 660.247010 0.000000',
 density           = '0.998240 0.000000 12.668720 -12.263280 64.657510 -2003.415040',
 c_range           = '0-1.875 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  81,
 units             = 'mM',
 description       = 'Sodium tartrate',
 viscosity         = '0.993710 36.820000 53.736000 74.550000 2470.199950 0.000000',
 density           = '0.998010 0.963170 13.535000 -12.500000 43.618000 -861.030030',
 c_range           = '0-1.75 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  82,
 units             = 'mM',
 description       = 'Sodium thiocyanate',
 viscosity         = '1.003290 -3.990000 3.883000 14.950000 26.400000 0.000000',
 density           = '1.001700 -13.693000 5.177700 -2.649800 2.616300 -11.012000',
 c_range           = '0-9.248 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  83,
 units             = 'mM',
 description       = 'Sodium thiosulfate',
 viscosity         = '1.071140 -442.340000 95.362000 -264.709990 1266.500000 0.000000',
 density           = '0.997760 3.556100 12.393000 -6.715500 9.507900 -91.718000',
 c_range           = '0-3.498 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  84,
 units             = 'mM',
 description       = 'Sodium tungstate',
 viscosity         = '1.008900 -107.330000 72.684000 -170.160000 323.899990 0.000000',
 density           = '0.995830 36.856000 11.497000 806.130000 -27379.000000 3401600.000000',
 c_range           = '0-332 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  85,
 units             = 'mM',
 description       = 'Strontium chloride',
 viscosity         = '1.038520 -227.770000 60.160000 -165.649990 712.299990 0.000000',
 density           = '0.998270 -0.090320 13.927000 -2.777400 -9.698000 259.850010',
 c_range           = '0-3.205 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  86,
 units             = 'mM',
 description       = 'Sucrose',
 viscosity         = '1.001100 -52.134910 107.945300 0.000000 11916.339840 0.000000',
 density           = '0.998270 -0.219630 13.237260 -1.836470 0.000000 -25.138710',
 c_range           = '0-3.53 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  87,
 units             = 'mM',
 description       = 'Sulfuric acid',
 viscosity         = '0.996460 0.000000 20.889120 0.000000 43.959960 0.000000',
 density           = '0.998170 2.051710 6.100520 -0.206390 -2.150380 17.650960',
 c_range           = '0-7.502 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  88,
 units             = 'mM',
 description       = 'Tartaric acid',
 viscosity         = '1.021700 -138.460010 54.553000 -82.490000 724.099980 0.000000',
 density           = '0.998150 1.610900 6.415800 0.854630 -4.943100 50.272000',
 c_range           = '0-5.099 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  89,
 units             = 'mM',
 description       = 'Tetracaine hydrochloride',
 viscosity         = '0.999580 0.000000 82.783000 1765.255000 0.000000 0.000000',
 density           = '0.998200 0.000000 3.880780 -1.066210 0.000000 0.000000',
 c_range           = '0-404 mM';

INSERT INTO bufferComponent SET
 bufferComponentID =  90,
 units             = 'mM',
 description       = 'Trichloroacetic acid',
 viscosity         = '1.001170 -38.086780 43.686690 28.552200 16.736100 0.000000',
 density           = '0.997630 0.000000 36.114190 95.545370 -285.511540 4695.838870',
 c_range           = '0-2.984 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  91,
 units             = 'mM',
 description       = 'Trifluoroethanol',
 viscosity         = '0.999070 -80.101140 24.863940 -16.105730 0.000000 0.000000',
 density           = '0.998120 3.830290 3.298380 -0.414390 0.000000 0.000000',
 c_range           = '0-13.901 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  92,
 units             = 'mM',
 description       = 'Tris(hydroxymethyl)aminomethane',
 viscosity         = '0.998460 0.000000 32.165560 59.464830 344.514010 0.000000',
 density           = '0.998230 0.000000 2.847170 1.310680 -3.935860 38.962850',
 c_range           = '0-3.657 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  93,
 units             = 'mM',
 description       = 'Urea',
 viscosity         = '1.002490 -19.458720 5.599690 -1.359290 6.838250 0.000000',
 density           = '0.998220 0.000000 1.490810 0.617290 -1.541420 10.260860',
 c_range           = '0-8.665 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  94,
 units             = 'mM',
 description       = 'Zinc sulfate',
 viscosity         = '0.999080 0.000000 62.032920 172.715320 1177.895020 0.000000',
 density           = '0.998250 -0.780880 16.947820 -22.172440 142.704350 -4038.580080',
 c_range           = '0-1.17 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  95,
 units             = 'mM',
 description       = 'DTT',
 viscosity         = '1.000000 0.000000 28.824000 0.000000 0.000000 0.000000',
 density           = '0.998200 0.000000 4.154280 0.000000 0.000000 0.000000',
 c_range           = '0-0.13 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  96,
 units             = 'mM',
 description       = 'HEPES',
 viscosity         = '1.000000 40.117010 43.691500 0.000000 0.000000 0.000000',
 density           = '0.998230 0.000000 7.762500 0.000000 0.000000 0.000000',
 c_range           = '0-0.08 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  97,
 units             = 'mM',
 description       = 'L-alanine',
 viscosity         = '1.000250 0.000000 17.134000 76.667000 0.000000 0.000000',
 density           = '0.998310 0.000000 2.818850 -2.175000 0.000000 0.000000',
 c_range           = '0-1.02 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  98,
 units             = 'mM',
 description       = 'L-arginine',
 viscosity         = '1.002000 -26.870000 69.387000 -269.300000 0.000000 0.000000',
 density           = '0.998230 0.000000 4.698000 0.000000 0.000000 0.000000',
 c_range           = '0-0.1 M';

INSERT INTO bufferComponent SET
 bufferComponentID =  99,
 units             = 'mM',
 description       = 'L-glycine',
 viscosity         = '1.002000 0.000000 14.586000 1.214000 0.000000 0.000000',
 density           = '0.998290 0.000000 3.131310 -0.312890 0.000000 0.000000',
 c_range           = '0-1.0 M';

INSERT INTO bufferComponent SET
 bufferComponentID = 100,
 units             = 'mM',
 description       = 'L-histidine',
 viscosity         = '1.000670 0.000000 9.104000 813.300000 0.000000 0.000000',
 density           = '0.998310 0.000000 5.634360 -10.457300 0.000000 0.000000',
 c_range           = '0-0.306 M';

INSERT INTO bufferComponent SET
 bufferComponentID = 101,
 units             = 'mM',
 description       = 'Sodium nitrate',
 viscosity         = '0.999430 2.710000 3.453000 19.790000 10.100000 0.000000',
 density           = '0.997720 2.834800 5.338900 -0.208800 -1.053100 10.065000',
 c_range           = '0-6.199 M';

INSERT INTO bufferComponent SET
 bufferComponentID = 102,
 units             = 'mM',
 description       = 'Sodium perchlorate',
 viscosity         = '1.000000 0.000000 -5.736970 25.641590 0.000000 0.000000',
 density           = '0.998230 -12.387980 12.422560 -108.304490 1302.919920 -55344.136720',
 c_range           = '0-1.124 M';

INSERT INTO bufferComponent SET
 bufferComponentID = 103,
 units             = 'mM',
 description       = 'Sorbitol',
 viscosity         = '1.000000 0.000000 61.500000 0.000000 0.000000 0.000000',
 density           = '0.999000 0.000000 6.470000 0.000000 0.000000 0.000000',
 c_range           = '0-0.55 M';

INSERT INTO bufferComponent SET
 bufferComponentID = 104,
 units             = 'mM',
 description       = 'Tween-80',
 viscosity         = '0.999960 0.000000 481.600000 129467.100000 0.000000 0.000000',
 density           = '0.998700 0.000000 14.230000 0.000000 0.000000 0.000000',
 c_range           = '0-0.07635 M';

