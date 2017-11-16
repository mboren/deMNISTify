"""
Train model on MNIST data and save to file
"""
import keras
from keras.layers import Dense
from keras.datasets import mnist
from keras.models import Sequential

file_name = 'mnist_model.h5'

# Data formatting

(x_train, y_train), (x_test, y_test) = mnist.load_data()

x_train = x_train.reshape(60000, 784)
x_train = x_train.astype('float32')

x_test = x_test.reshape(10000, 784)
x_test = x_test.astype('float32')

x_train /= 255
x_test /= 255

y_train = keras.utils.to_categorical(y_train, 10)
y_test = keras.utils.to_categorical(y_test, 10)

# Setup model architecture

model = Sequential()
model.add(Dense(units=30, activation='sigmoid', input_dim=784))
model.add(Dense(units=10, activation='sigmoid'))

# Fit model

model.compile(loss='categorical_crossentropy',
              optimizer='sgd',
              metrics=['accuracy'])

model.fit(x_train,y_train,
          epochs=30,
          batch_size=30,
          verbose=2,
          validation_data=(x_test,y_test) )

model.save(file_name)

score, accuracy = model.evaluate(x_test,y_test)
print('score', score)
print('accuracy', accuracy)
