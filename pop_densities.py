import csv

outputs = []
first = True
with open('CountyPopulations.csv', newline='') as csvfile:
    filereader = csv.reader(csvfile, delimiter=',', quotechar='"')
    for row in filereader:
        if not first:
            outputs.append((row[1], row[2],
                            str(float(row[1]) / float(row[2]))))
        first = False

f = open('PopulationDistribution.csv', 'w')
for x in outputs:
    f.write(x[0])
    f.write(", ")
    f.write(x[1])
    f.write(", ")
    f.write(x[2])
    f.write("\n")

f.close()
