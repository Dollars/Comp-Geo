import matplotlib.pyplot as plt
from shapely.geometry import point
from canvas import Canvas
import canvas

class Triangle(Canvas):

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
            a = self.vert[0]
            b = self.vert[1]
            c = self.vert[2]
            p = point.Point(self.x, self.y)
            self.path.set_color(canvas.COLOR[self.is_clockwise(a, b, c)])
            self.point = self.ax.scatter(self.x, self.y, color=canvas.COLOR[self.is_in_triangle(a, b, c, p)])

        self.path.set_data(x, y)
        plt.draw()