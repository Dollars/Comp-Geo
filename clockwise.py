from __future__ import print_function
import matplotlib
matplotlib.use('Qt4Agg')
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

        self.mouse_button = {1: self._add_point, 2: self._delete_point}
        plt.draw()

    def clockwise(self, a, b, c):
        z  = (b.x - a.x) * (c.y - b.y);
        z -= (b.y - a.y) * (c.x - b.x);
        return z < 0

    def set_location(self, event):
        if event.inaxes == self.ax:
            self.x = event.xdata
            self.y = event.ydata

    def _add_point(self):
        if (len(self.vert) < self.sides_lim):
            self.vert.append(point.Point(self.x, self.y))

    def _delete_point(self):
        if len(self.vert) > 0:
            self.vert.pop()

    def _close_polygon(self):
        pass

class Triangle(Canvas):
    def is_in(self, poly, point):
        sens = self.clockwise(poly[0], poly[1], poly[2])
        for i in range(len(poly)):
            if (sens != self.clockwise(poly[i], poly[(i+1)%len(poly)], point)):
                return not sens
        return sens

    def update_path(self, event):

        # If the mouse pointer is not on the canvas, ignore buttons
        if not event.inaxes or event.inaxes != self.ax: return

        # Do whichever action correspond to the mouse button clicked
        self.mouse_button[event.button]()

        size = range(len(self.vert))
        size.append(0)
        x = [self.vert[k].x for k in size]
        y = [self.vert[k].y for k in size]
        if(len(self.vert) >= self.sides_lim):
            self.path.set_color(COLOR[self.clockwise(self.vert[0], self.vert[1], self.vert[2])])
            self.point = self.ax.scatter(self.x, self.y, color=COLOR[self.is_in(self.vert, point.Point(self.x, self.y))])

        self.path.set_data(x, y)
        plt.draw()

class Hull(Canvas):
    def __init__(self, ax, sides=100):
        super(Hull, self).__init__(ax, sides)
        self.ch = []
        self.mouse_button[3] = self._close_polygon()

    def sort_points(self, points, descending=True):
        def lt (u, v):
            if v.x == u.x:
                if v.y == u.y:
                    return 0
                else:
                    return int((v.y - u.y)/abs(v.y - u.y))
            else:
                return int((u.x - v.x)/abs(u.x - v.x))

        def gt (u, v):
            if v.x == u.x:
                if v.y == u.y:
                    return 0
                else:
                    return -int((v.y - u.y)/abs(v.y - u.y))
            else:
                return -int((u.x - v.x)/abs(u.x - v.x))
        if descending:
            points.sort(cmp=lt)
        else:
            points.sort(cmp=gt)

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
                if (end_point == start_point) or not self.clockwise(p[i], end_point, points[j]):
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
                if (end_point == start_point) or not self.clockwise(p[i], end_point, points[j]):
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

if __name__ == "__main__":
    print('Do something before plotting.')
    plt.ion()
    fig = plt.figure(1, figsize=SIZE, dpi=90)

    ax = fig.add_subplot(1, 2, 1, axisbg='#2D333A')
    ax.set_aspect(1)
    tr = Triangle(ax)

    fig.canvas.mpl_connect('button_press_event', tr.update_path)
    fig.canvas.mpl_connect('motion_notify_event', tr.set_location)

    ax = fig.add_subplot(1, 2, 2, axisbg='#2D333A')
    ax.set_aspect(1)
    tr2 = Hull(ax)

    fig.canvas.mpl_connect('button_press_event', tr2.update_path)
    fig.canvas.mpl_connect('motion_notify_event', tr2.set_location)

    plt.show(block=True)
    print('Do something after plotting.')
