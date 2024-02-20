# Format
# [Frame] [X] [Y] [Rho] [Deg] [Vrho] [Vdeg] [ID]

angle = 0
with open('script.txt', 'w') as f:
    for frame in range(1, 2048, 2):
        for x in range(0, 1):
            y = (-2 / 9) * x + 14 / 3
            angle = angle + y
            theta1 = 180 - 140 / 3
            theta2 = theta1 + 180
            velocity = 1.46 + x / 876
            # print(frame, 400, 300, 0, int(angle + theta1), int(velocity), 0, 0)
            f.write(str(frame) + ' ' + str(400) + ' ' + str(300) + ' ' + str(0) + ' ' + str(int(angle + theta1) % 360) + ' ' + str(int(velocity)) + ' ' + str(0) + ' ' + str(63) + '\n')
            # print(frame, 400, 300, 0, int(angle + theta2), int(velocity), 0, 1)
            f.write(str(frame) + ' ' + str(400) + ' ' + str(300) + ' ' + str(0) + ' ' + str(int(angle + theta2) % 360) + ' ' + str(int(velocity)) + ' ' + str(0) + ' ' + str(63) + '\n')
        
