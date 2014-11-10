from canvas import Canvas
import matplotlib.pyplot as plt
from shapely.geometry import point

class Point_set(Canvas):
    def __init__(self, ax, sides=100):
        super(Point_set, self).__init__(ax, sides)

    def ch_points(self, points):
        if(len(points) < 4): return points
        size = len(points)
        vertices = []
        for s in range(size):
            valid = True
            for i in range(size):
                for j in range(size):
                    for k in range(size):
                        if len(set([s, i, j, k])) == 4:
                            valid &= not self.is_in_triangle(points[i], points[j], points[k], points[s])
                            if not valid:
                                break
                    if not valid:
                        break
                if not valid:
                    break
            if valid == True:
                vertices.append(points[s])
        return vertices

    def sort_ch_points(self, points):
        self.sort_points(points)
        p = points[:]
        points = []
        start_point = p.pop(0)
        points.append(start_point)

        while len(p) != 0:
            for i in range(len(p)):
                next_point = True
                for j in range(len(p)):
                    if j != i:
                        next_point = not self.is_ccw(start_point, p[i], p[j])
                        if not next_point:
                            break
                if next_point:
                    start_point = p.pop(i)
                    points.append(start_point)
                    break
        return points

    def update_path(self, event):

        # If the mouse pointer is not on the canvas, ignore buttons
        if not event.inaxes or event.inaxes != self.ax: return

        # Do whichever action correspond to the mouse button clicked
        self.mouse_button[event.button]()
        self.ax.texts= []
        size = range(len(self.vert))
        x = [self.vert[k].x for k in size]
        y = [self.vert[k].y for k in size]

        s = self.ch_points(self.vert)
        color = ['#D62A37'] * len(self.vert)
        for k in size:
            if self.vert[k] in s:
                color[k] = '#3AF26E'
        
        self.ax.scatter(x, y, c=color)

        s = self.sort_ch_points(s)
        size = range(len(s))
        x = [s[k].x for k in size]
        y = [s[k].y for k in size]
        for i, txt in enumerate(size):
            self.ax.annotate(txt, (x[i], y[i]), color='grey')
        plt.draw()
