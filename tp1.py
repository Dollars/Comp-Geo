import matplotlib.pyplot as plt
import canvas
from triangle import Triangle
from set_point import Point_set

if __name__ == "__main__":
    fig = plt.figure(1, figsize=canvas.SIZE, dpi=90)

    ax = fig.add_subplot(1, 2, 1, axisbg='#2D333A')
    ax.grid(b=True, which='both', color='#444B53', linestyle='-')
    ax.set_aspect(1)
    tr = Triangle(ax)
    fig.canvas.mpl_connect('button_press_event', tr.update_path)
    fig.canvas.mpl_connect('motion_notify_event', tr.set_location)

    ax = fig.add_subplot(1, 2, 2, axisbg='#2D333A')
    ax.grid(b=True, which='both', color='#444B53', linestyle='-')
    ax.set_aspect(1)
    ps = Point_set(ax)
    fig.canvas.mpl_connect('button_press_event', ps.update_path)
    fig.canvas.mpl_connect('motion_notify_event', ps.set_location)

    plt.show()