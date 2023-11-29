
implementation = ["fully_serial", "semi_serial", "fully_parallel"]
attribute = ["cells", "power", "timing"]
#attribute = ["power"]


for j in range(len(implementation)):
    print("NEW implementation: "+implementation[j])
    for i in range(len(attribute)):
        print("Starting: "+ attribute[i])

        N = 2
        while N <= 64:

            QM = 3
            QN = 5

            while (QM <= 12 and QN <= 20):

                fileName = "./data/"+implementation[j]+"_N-"+str(N)+",QM-"+str(QM)+",QN-"+str(QN)+"_"+attribute[i]+".txt"

                with open(fileName, 'r') as f:
                    for line in f:
                    
                        # look at line in loop
                        lineArr = line.split()

                        #cells
                        if (i == 0):
                            if (len(lineArr) > 1):
                                if (lineArr[0] == "Total" and lineArr[1] != "Dynamic"):
                                    finalVal = str(lineArr[-1])
                                    print(implementation[i], "&", str(N), "&", str(QM), "&", str(QN), "&", finalVal, "\\" + "\\" ,end='\n')
                        #power
                        elif (i == 1):
                            if (len(lineArr) > 1):
                                if (lineArr[0] == "Total" and lineArr[1] != "Dynamic"):
                                    finalVal = str(lineArr[-2])+" "+str(lineArr[-1])
                                    print(finalVal ,end='\n')
                        else:
                            if (len(lineArr) > 0):
                                if (lineArr[0] == "slack"):
                                    finalVal = str(1/(100 - float(lineArr[-1]))*10**(3))
                                    print(finalVal ,end='\n')



                QM = 2*QM
                QN = 2*QN
            N = 2*N
                

        
        
        
        
    

    





#print(fileName)
