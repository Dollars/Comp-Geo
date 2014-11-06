from matplotlib import pyplot as plt
from shapely.geometry import point
from shapely.geometry import LineString

SIZE = (10,10)

COLOR = {
    True:  '#3AF26E',
    False: '#D62A37'
    }

def v_color(ob):
    return COLOR[ob.is_simple]

def plot_coords(ax, ob):
    x, y = ob.xy
    ax.plot(x, y, 'o', color='#999999', zorder=1)

def plot_bounds(ax, ob):
    x, y = zip(*list((p.x, p.y) for p in ob.boundary))
    ax.plot(x, y, 'o', color='#000000', zorder=1)

def plot_line(ax, ob):
    x, y = ob.xy
    ax.plot(x, y, color=v_color(ob), alpha=0.7, linewidth=3, solid_capstyle='round', zorder=2)

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
        self.ax.set_title('LEFT: new point, MIDDLE: delete last point, RIGHT: close polygon')

        self.x = []
        self.y = []

        self.mouse_button = {1: self._add_point, 2: self._delete_point, 3: self._close_polygon}

    def clockwise(self, a, b, c):
        z  = (b.x - a.x) * (c.y - b.y);
        z -= (b.y - a.y) * (c.x - b.x);
        return z < 0

    def set_location(self, event):
        if event.inaxes:
            self.x = event.xdata
            self.y = event.ydata
               
    def _add_point(self):
        if (len(self.vert) < self.sides_lim):
            self.vert.append(point.Point(self.x, self.y))
            if (len(self.vert) == self.sides_lim):
                self._close_polygon()

    def _delete_point(self):
        if len(self.vert)>0:
            self.vert.pop()

    def _close_polygon(self):
        self.vert.append(self.vert[0])

    def update_path(self, event):

        # If the mouse pointer is not on the canvas, ignore buttons
        if not event.inaxes: return

        # Do whichever action correspond to the mouse button clicked
        self.mouse_button[event.button]()
        
        x = [self.vert[k].x for k in range(len(self.vert))]
        y = [self.vert[k].y for k in range(len(self.vert))]
        if(len(self.vert) >= self.sides_lim):
            self.path.set_color(COLOR[self.clockwise(self.vert[0], self.vert[1], self.vert[2])])
        self.path.set_data(x, y)
        plt.draw()

fig = plt.figure(1, figsize=SIZE, dpi=90)

# 1: simple line
ax = fig.add_subplot(1, 1, 1, axisbg='#2D333A')
cnv = Canvas(ax)

plt.connect('button_press_event',cnv.update_path)
plt.connect('motion_notify_event',cnv.set_location)

plt.show()
