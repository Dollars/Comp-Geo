import matplotlib.pyplot as plt
import canvas
from convex_hull import Polygon
from polygon import Convex_polygon

if __name__ == "__main__":
    fig = plt.figure(1, figsize=canvas.SIZE, dpi=90)

    ax = fig.add_subplot(1, 2, 1, axisbg='#2D333A')
    ax.grid(b=True, which='both', color='#444B53', linestyle='-')
    ax.set_aspect(1)
    chl = Polygon(ax)
    fig.canvas.mpl_connect('button_press_event', chl.update_path)
    fig.canvas.mpl_connect('motion_notify_event', chl.set_location)

    ax = fig.add_subplot(1, 2, 2, axisbg='#2D333A')
    ax.grid(b=True, which='both', color='#444B53', linestyle='-')
    ax.set_aspect(1)
    cp = Convex_polygon(ax)
    fig.canvas.mpl_connect('button_press_event', cp.update_path)
    fig.canvas.mpl_connect('motion_notify_event', cp.set_location)

    plt.show()