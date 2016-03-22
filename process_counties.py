import csv

names = []
coordslist = []
count = 0
with open('MississippiCounties.csv', newline='') as csvfile:
    filereader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in filereader:
        if count >= 1: #skip first line
            names.append(row[0])
            coordslist.append(row[4])
        count += 1

coords_converted = []
for x in coordslist:
    spl = x.split(' ')
    coords = []
    for i in range(len(spl)):
        if i == 0: 
            spl[i] = spl[i][51:]
        if i == len(spl)-1:
            spl[i] = spl[i][:-55]
        tpl = spl[i].partition(',')
        coords.append((tpl[0],tpl[2]))       
    coords_converted.append(coords)    

f = open('CountyBoundaries.csv', 'w')
for i in range(len(names)):
    f.write(str(len(coords_converted[i])))
    f.write(", ")
    for x in coords_converted[i]:
        f.write(x[0] + ", ")
    for x in coords_converted[i][:-1]:
        f.write(x[1] + ", ")
    f.write(coords_converted[i][-1][1] + "\n")

f.close()
