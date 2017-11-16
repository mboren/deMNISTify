"""Interactive plots used for playing with models trained on image data

InteractiveMnistPlot enables several forms of interactivity:
- You can draw on the plot with your mouse.
- Pressing any key will erase the plot.
- The plot title will be automatically updated with the output of your
   recognition function as you draw.

  This was written with MNIST and digit recognition in mind, but it should be
fairly generic. Any scenario where you can take monochrome images as input
and return output that looks reasonable when passed through str() should
work out of the box.
  To make it more generic, the drawing code would need to be more configurable,
and one might want to replace ax.set_title with a function that takes the plot
and the output of recognition_func as params and modifies the plot.
"""
import numpy as np

class InteractiveMnistPlot:
    def __init__(self, ax, plot, data, recognition_func):
        self.drawing = False
        self.ax = ax
        self.plot = plot
        self.data = data
        self.ax.set_title('?')
        self.recognition_func = recognition_func

        # These properties are never used directly, they're only stored to prevent them
        # from getting garbage collected
        self.cid_motion = self.plot.figure.canvas.mpl_connect('motion_notify_event', self.on_mouse_move)
        self.cid_mouse_down = self.plot.figure.canvas.mpl_connect('button_press_event', self.on_mouse_down)
        self.cid_mouse_up = self.plot.figure.canvas.mpl_connect('button_release_event', self.on_mouse_up)
        self.cid_key_up = self.plot.figure.canvas.mpl_connect('key_release_event', self.on_key_up)

    def on_mouse_down(self, event):
        self.drawing = True

    def on_mouse_up(self, event):
        self.drawing = False

    def on_key_up(self, event):
        """Erase drawn image after any key is pressed"""
        self.data = np.zeros_like(self.data)
        self.plot.set_data(self.data)
        self.ax.set_title('?')

        self.plot.figure.canvas.draw()

    def on_mouse_move(self, event):
        if self.drawing:
            if event.xdata is not None and event.ydata is not None:
                # Mouse event coordinates have integer values in the center of image
                # pixels, whereas image coordinates have integer values at pixel corners,
                # so we need to shift the coordinates, floor them, and then clamp
                # inside image bounds.
                x = min(self.data.shape[1]-1, max(0, int(event.xdata + 0.5)))
                y = min(self.data.shape[0]-1, max(0, int(event.ydata + 0.5)))

                self.data[y, x] = 1

                # Add 0.5 to neighboring pixels. The lighter edges improve recognition
                # accuracy because it makes the drawn images more similar to original
                # MNIST data. I suspect that this would not be necessary with a
                # convolutional neural network.
                for dy in [-1, 0, 1]:
                    yn = y + dy
                    for dx in [-1, 0, 1]:
                        xn = x + dx
                        if 0 < yn < self.data.shape[0] and 0 < xn < self.data.shape[1]:
                            self.data[yn, xn] = min(1, self.data[yn, xn] + 0.5)

                # Set plot title to prediction
                recognized = self.recognition_func(self.data)
                self.ax.set_title(str(recognized))

                self.plot.set_data(self.data)
                self.plot.figure.canvas.draw()

