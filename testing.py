matrix = [  [0,0,0,0],
            [0,0,0,0],
            [0,0,0,0],
            [0,0,0,0]
            ]
def spiral(X, Y):
    x = y = 0
    dx = 0
    dy = -1
    for i in range(max(X, Y)**2):
        if (-X/2 < x <= X/2) and (-Y/2 < y <= Y/2):
            print("move forward")
            matrix[x][y] = 1
            print(matrix)
        if x == y or (x < 0 and x == -y) or (x > 0 and x == 1-y):
            dx, dy = -dy, dx
            print("turn left")
            matrix[x][y] = 1
            print(matrix)
        x, y = x+dx, y+dy
        

if __name__ == "__main__":
    spiral(4, 4)