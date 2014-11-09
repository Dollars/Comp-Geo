import matplotlib.pyplot as plt
import canvas
from convex_hull import Polygon

if __name__ == "__main__":
    fig = plt.figure(1, figsize=canvas.SIZE, dpi=90)

    ax = fig.add_subplot(1, 1, 1, axisbg='#2D333A')
    ax.grid(b=True, which='both', color='#444B53', linestyle='-')
    ax.set_aspect(1)
    chl = Polygon(ax)
    fig.canvas.mpl_connect('button_press_event', chl.update_path)
    fig.canvas.mpl_connect('motion_notify_event', chl.set_location)

    plt.show()