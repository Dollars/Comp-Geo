from canvas import Canvas
import matplotlib.pyplot as plt
from shapely.geometry import point

class Polygon(Canvas):
    def __init__(self, ax, sides=100):
        super(Polygon, self).__init__(ax, sides)

    def up_hull(self, points):
        if(len(points) < 3): return []
        self.sort_points(points)
        p = []
        start_point = points[0]
        i = 0
        while True:
            p.insert(i, start_point)
            for q in points:
                end_point = q
                if end_point != q:
                    break
            for j in range(1, len(points)):
                if (end_point == start_point) or not self.is_clockwise(p[i], end_point, points[j]):
                    end_point = points[j]
            ++i
            start_point = end_point
            if(end_point == p[0]):
                break
        return p

    def down_hull(self, points):
        if(len(points) < 3): return []
        self.sort_points(points, descending=False)
        p = []
        start_point = points[0]
        i = 0
        while True:
            p.insert(i, start_point)
            for q in points:
                end_point = q
                if end_point != q:
                    break
            for j in range(1, len(points)):
                if (end_point == start_point) or not self.is_clockwise(p[i], end_point, points[j]):
                    end_point = points[j]
            ++i
            start_point = end_point
            if(end_point == p[0]):
                break
        return p

    def update_path(self, event):

        # If the mouse pointer is not on the canvas, ignore buttons
        if not event.inaxes or event.inaxes != self.ax: return

        # Do whichever action correspond to the mouse button clicked
        self.mouse_button[event.button]()

        size = range(len(self.vert))
        x = [self.vert[k].x for k in size]
        y = [self.vert[k].y for k in size]
        self.ax.scatter(x, y)

        s = self.up_hull(self.vert)
        s += self.down_hull(self.vert)

        if len(s) > 2:
            size = range(len(s))
            x = [s[k].x for k in size]
            y = [s[k].y for k in size]
            self.path.set_data(x, y)

        plt.draw()
