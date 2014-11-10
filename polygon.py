from canvas import Canvas, COLOR
import matplotlib.pyplot as plt
from shapely.geometry import point

class Convex_polygon(Canvas):
    def __init__(self, ax, sides=100):
        super(Convex_polygon, self).__init__(ax, sides)
        self.ax.set_title('Left button for vertices. Right button to test points')

    def _close_polygon(self):
        self.sides_lim = len(self.vert)

    def up_hull(self, points):
        if(len(points) < 3): return points
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
                if (end_point == start_point) or not self.is_ccw(p[i], end_point, points[j]):
                    end_point = points[j]
            ++i
            start_point = end_point
            if(end_point == p[0]):
                break
        return p

    def down_hull(self, points):
        if(len(points) < 3): return [points[0]]
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
                if (end_point == start_point) or not self.is_ccw(p[i], end_point, points[j]):
                    end_point = points[j]
            ++i
            start_point = end_point
            if(end_point == p[0]):
                break
        return p

    def is_in_polygon(self, point, poly):
        is_in = True
        for i in range(len(poly)):
            a, b = poly[i], poly[(i+1)%len(poly)]
            is_in = not self.is_ccw(a, b, point)
            if not is_in:
                return False
        return True

    def find_tangent(self, point, poly):
        for i in range(len(poly)):
            a = poly[i-1]
            b = poly[i]
            c = poly[(i+1)%len(poly)]
            if (self.is_ccw(point, b, a) == True and self.is_ccw(point, b, c) == True):
                t1 = poly[i]
            elif (self.is_ccw(point, b, a) == False and self.is_ccw(point, b, c) == False):
                t2 = poly[i]
        return t1, t2

    def update_path(self, event):

        # If the mouse pointer is not on the canvas, ignore buttons
        if not event.inaxes or event.inaxes != self.ax: return

        self.ax.collections = []
        self.ax.lines = [self.ax.lines[0]]
        # Do whichever action correspond to the mouse button clicked
        self.mouse_button[event.button]()

        s = self.up_hull(self.vert)
        s += self.down_hull(self.vert)[1:]

        if len(s) <= 2:
            size = range(len(s))
            x = [s[k].x for k in size]
            y = [s[k].y for k in size]
            self.path.set_data(x, y)
        else:
            size = range(len(s))
            x = [s[k].x for k in size]
            y = [s[k].y for k in size]
            self.path.set_data(x, y)
            if len(self.vert) == self.sides_lim:
                p = point.Point(self.x, self.y)
                is_in = self.is_in_polygon(p, s)
                self.ax.scatter(self.x, self.y, color=COLOR[is_in])
                if not is_in:
                    a, b = self.find_tangent(p, s[1:])
                    self.ax.plot([p.x, a.x], [p.y, a.y], 'o-', lw=3)
                    self.ax.plot([p.x, b.x], [p.y, b.y], 'o-', lw=3)

        plt.draw()
