# deMNISTify

Train a classifier on MNIST, then draw numbers and see the output of the classifier
updated live as you draw.
 
[demo](http://s3.us-west-1.amazonaws.com/hi-mom-im-on-the-internet/mnist.html)

I'm using ![mboren/model-server](https://github.com/mboren/model-server) running on a free dyno from Heroku for the demo backend, so it might take a minute or two to wake up when you first open the page.
 
![animation showing Elm app recognizing multiple digits](demo.gif)

Digit recognition is done with a Convolutional Neural Network implemented with Keras and Tensorflow.

There are two different ways you can run this thing:
1. a pure python program implementation that uses matplotlib for the UI
2. a web app that uses [Elm](http://elm-lang.org/) for the frontend and a Python websocket server for the backend

They have essentially equivalent functionality; the web version was written purely
because I like having a demo I can link to.

# Dependencies
- Python 3.6
- Python libraries:
    - matplotlib, scikit-image, numpy, keras, tensorflow
    - websockets (only required if you want to run the websocket server)
- Elm 0.18

# Matplotlib instructions
After using conda or pip to install: matplotlib, scikit-image, numpy, and keras:
```
$ cd backend
$ python train_model.py
```
After training finishes (which can take a while):
```
$ python matplotlib_frontend.py
```
Draw on the plot that comes up by dragging with your mouse, and press any key to erase.

# Web app instructions
First you'll have to run a server:
```
cd backend
python train_model.py
python server.py --address localhost --port 8765
```

Then, build and run the Elm app:
```
$ cd ../frontend
$ elm-package install
$ elm-make src/App.elm --output=app.html
```

Open frontend/app.html in a web browser. If you draw on the page that comes up,
you should see the question mark in the bottom left of the page turn into a
number. If it doesn't, something went wrong on the python side.

The server address is hardcoded in `frontend/src/App.elm` code due to \<insert weak excuses\>, so if you want to point this at a remote server you'll need to update
that manually.

# Browser compatibility
It should work in any modern desktop browser, but I've only tried this in Google Chrome and Microsoft Edge.
It works fine in both, but Edge makes adjacent polygons in SVGs look prettier.

The Elm app does not respond to touch events, so, even though it'll run in mobile
browsers, you won't be able to interact with it at all.
