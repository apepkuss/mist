# import numpy as np
# import PIL
# from PIL import Image
import httpx
import msgpack
import modelz
from PIL import Image
import numpy as np

APIKey = "mzi-510edb7dff018ec70bc8e82671552dcc"
DeploymentKey = "mist-hia1y6nihmn9fa3v"

# load image
img = Image.open("./test/sample.png")
print(f"img size: {img.size}")

# convert to numpy array (for getting `shape`) then to bytes
array = np.array(img)
img_shape = array.shape
print(f"array shape: {img_shape}")
img_bytes = array.tobytes()
print(f"size of bytes: {len(img_bytes)}")

# create a modelz client
cli = modelz.ModelzClient(key=APIKey, deployment=DeploymentKey, timeout=300)

params = msgpack.packb(
    {
        # "output_size": 512,
        "epsilon": 16,
        "steps": 100,
        "block_num": 1,
        "mode": 2,
        "rate": 1,
    }
)
params["image"] = {
    "data": img_bytes,
    "shape": img_shape,
}

response = cli.inference(params=params, serde="msgpack")

if response.status_code == 200:
    print(msgpack.unpackb(response.content))
else:
    print(response.status_code, response.content)


# img_bytes = httpx.get(
#     "https://github.com/apepkuss/mist/blob/a326f235eaf472592c8f099592b235c8b9c86d2c/test/sample.png"
# ).content

# prediction = httpx.post(
#     "https://mist-hia1y6nihmn9fa3v.modelz.io/",
#     data=msgpack.packb(
#         {
#             "image": img_bytes,
#             "output_size": 512,
#             "epsilon": 16,
#             "steps": 100,
#             "block_num": 1,
#             "mode": 2,
#             "rate": 1,
#         }
#     ),
# )

# if prediction.status_code == 200:
#     print(msgpack.unpackb(prediction.content))
# else:
#     print(prediction.status_code, prediction.content)
