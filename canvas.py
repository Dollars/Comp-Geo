from __future__ import print_function
import matplotlib.pyplot as plt
from shapely.geometry import point
from shapely.geometry import LineString

SIZE = (10, 10)

COLOR = {
    True:  '#3AF26E',
    False: '#D62A37'
}

class Canvas(object):
    def __init__(self, ax, sides=3):
        self.ax = ax

        self.sides_lim = sides

        # Set limits to unit square
        self.ax.set_xlim((0,10))
        self.ax.set_ylim((0,10))

        # Create handle for a path of connected points
        self.path, = ax.plot([], [], 'o-', lw=3)
        self.vert = []
        self.ax.set_title('')

        self.x = []
        self.y = []
        self.point = self.ax.scatter(self.x, self.y)

        self.mouse_button = {1: self._add_point, 2: self._delete_point, 3: self._close_polygon}
        plt.draw()

    def is_clockwise(self, a, b, c):
        return (b.y - a.y)*(c.x - a.x) < (b.x - a.x)*(c.y - a.y)

    def set_location(self, event):
        if event.inaxes == self.ax:
            self.x = event.xdata
            self.y = event.ydata

    def is_in_triangle(self, a, b, c, p):
        sens = self.is_clockwise(a, b, c)
        tri = [a,b,c]
        for i in range(len(tri)):
            if (sens != self.is_clockwise(tri[i], tri[(i+1)%len(tri)], p)):
                return False
        return True

    def point_lt (self, u, v):
        if v.x == u.x:
            if v.y == u.y:
                return 0
            else:
                return int((v.y - u.y)/abs(v.y - u.y))
        else:
            return int((u.x - v.x)/abs(u.x - v.x))

    def point_gt (self, u, v):
        if v.x == u.x:
            if v.y == u.y:
                return 0
            else:
                return -int((v.y - u.y)/abs(v.y - u.y))
        else:
            return -int((u.x - v.x)/abs(u.x - v.x))

    def sort_points(self, points, descending=True):
        if descending:
            points.sort(cmp=self.point_lt)
        else:
            points.sort(cmp=self.point_gt)

    def _add_point(self):
        if (len(self.vert) < self.sides_lim):
            self.vert.append(point.Point(self.x, self.y))

    def _delete_point(self):
        if len(self.vert) > 0:
            self.vert.pop()

    def _close_polygon(self):
        pass
