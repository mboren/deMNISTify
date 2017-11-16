import asyncio
import websockets
import json
import numpy as np
import argparse
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


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--modelfile', default='mnist_model.h5', type=str, help='Path to trained model stored in a file that keras.models.load_model will understand')
    parser.add_argument('--address', default='localhost', type=str, help='URL to serve from')
    parser.add_argument('--port', default=8765, type=int, help='Port to serve from')

    args = parser.parse_args()

    model = load_model(args.modelfile)

    asyncio.get_event_loop().run_until_complete(
        websockets.serve(echo, args.address, args.port)
    )
    asyncio.get_event_loop().run_forever()
