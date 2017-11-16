import asyncio
import websockets
import json
import numpy as np
from keras.models import load_model
from utilities import recognize_digit


async def echo(socket, _):
    """When image is received from socket, send predicted digit back.

    websockets.serve expects this to have 2 arguments. We only need the
    first, so the second is ignored.
    """
    async for message in socket:
        res = (recognize_digit(model, np.asarray(json.loads(message))))
        await socket.send(str(res))


model = load_model('mnist_model.h5')

asyncio.get_event_loop().run_until_complete(
    websockets.serve(echo, 'localhost', 8765)
)
asyncio.get_event_loop().run_forever()
