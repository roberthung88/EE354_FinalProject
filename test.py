import numpy as np

input_arr = [[0]*8]*8
input_arr = np.array([[6, 1, 1, 0, 0, 0, 0, 0],
             [4, -2, 5, 0, 0, 0, 0, 0],
             [2, 8, 7, 0, 0, 0, 0, 0],
             [0, 0, 0, 1, 0, 0, 0, 0],
             [0, 0, 0, 0, 1, 0, 0, 0],
             [0, 0, 0, 0, 0, 1, 0, 0],
             [0, 0, 0, 0, 0, 0, 1, 0],
             [0, 0, 0, 0, 0, 0, 0, 1]])
print(input_arr)
det = 0

seven = [[0]*7]*7
six = [[0]*6]*6
five = [[0]*5]*5
four = [[0]*4]*4
three = [[0]*3]*3

temp_val = [0]*6
size_curr = 7
sub_index = [0]*5
state = 2

while True:
    if state == 2:
        #load state
        state = 3
        if size_curr == 3:
            three = four[1:,:]
            three = np.delete(three, sub_index[4], axis=1)
            # print("Three Done: ")
            # print(three)
        elif size_curr == 4:
            four = five[1:,:]
            four = np.delete(four, sub_index[3], axis=1)
            # print("Four Done: ")
            # print(four)
        elif size_curr == 5:
            five = six[1:,:]
            five= np.delete(five, sub_index[2], axis=1)
            # print("Five Done: ")
            # print(five)
        elif size_curr == 6:
            six = seven[1:,:]
            six = np.delete(six, sub_index[1], axis=1)
            # print("Six Done: ")
            # print(six)
        elif size_curr == 7:
            seven = input_arr[1:,:]
            seven = np.delete(seven, sub_index[0], axis=1)
            # print("Seven Done: ")
            # print(seven)
    elif state == 3:
        # comp state 
        state = 2
        if size_curr != 3:
            size_curr -= 1
        else:
            a = three[0][0]
            b = three[0][1]
            c = three[0][2]
            d = three[1][0]
            e = three[1][1]
            f = three[1][2]
            g = three[2][0]
            h = three[2][1]
            i = three[2][2]

            temp_val[5] = a*(e*i-f*h) - b*(d*i-f*g) + c*(d*h-e*g)
            # print("Temp Val!")
            # print(temp_val)

           

            if sub_index[4] % 2 == 0:
                temp_val[4] += (temp_val[5]*four[0][sub_index[4]])
            else:
                temp_val[4] -= (temp_val[5]*four[0][sub_index[4]])

            if(sub_index[4] == 3):
                sub_index[4] = 0
                size_curr+=1
                #update values
                if(sub_index[3] % 2 == 0):
                    temp_val[3] += (temp_val[4]*five[0][sub_index[3]])
                else:
                    temp_val[3] -= (temp_val[4]*five[0][sub_index[3]])
                temp_val[4] = 0

                #calculated very last 4x4 matrix
                if(sub_index[3] == 4):
                    sub_index[3] = 0
                    size_curr+=1
                    #update values
                    if(sub_index[2] % 2 == 0):
                        temp_val[2] += (temp_val[3]*six[0][sub_index[2]])
                    else:
                        temp_val[2] -= (temp_val[3]*six[0][sub_index[2]])
                    temp_val[3] = 0

                    #calculated very last 5x5 matrix
                    if(sub_index[2] == 5):
                        sub_index[2] = 0
                        size_curr+=1
                        #update values
                        if(sub_index[1] % 2 == 0):
                            temp_val[1] += (temp_val[2]*seven[0][sub_index[1]])
                        else:
                            temp_val[1] -= (temp_val[2]*seven[0][sub_index[1]])
                        temp_val[2] = 0

                        #calculated very last 6x6 matrix
                        if(sub_index[1] == 6):
                            sub_index[1] = 0
                            size_curr+=1
                            #update values
                            if(sub_index[0] % 2 == 0):
                                temp_val[0] += (temp_val[1]*input_arr[0][sub_index[0]])
                            else:
                                temp_val[0] -= (temp_val[1]*input_arr[0][sub_index[0]])
                            

                            #calculated very last 7x7 matrix
                            if(sub_index[0] == 7):
                                #calculated everything
                                temp_val[0] -= (temp_val[1]*input_arr[0][sub_index[0]])
                                det = temp_val[0]
                                break
                            else:
                                temp_val[1] = 0
                                sub_index[0]+=1
                            
                        else:
                            sub_index[1]+=1
                        
                    else:
                        sub_index[2]+=1
                    
                else:
                    #calculate next 4x4
                    sub_index[3]+=1
            else:
                #haven't calculated very last 3x3 matrix, so calculate next 3x3 det
                sub_index[4]+=1
                temp_val[5] = 0
        

print("Correct det: ", np.linalg.det(input_arr))
print("My Solution: ", det)