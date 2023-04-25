import msgpack
import modelz

APIKey = "mzi-510edb7dff018ec70bc8e82671552dcc"
DeploymentKey = "mist-g558664cd4aew1tl"

# create a modelz client
cli = modelz.ModelzClient(key=APIKey, deployment=DeploymentKey, timeout=60 * 15)

params = msgpack.packb(
    {
        "image_url": "https://raw.githubusercontent.com/apepkuss/mist/main/test/sample.png",
        "output_size": 512,
        "epsilon": 16,
        "steps": 100,
        "block_num": 1,
        "mode": 2,
        "rate": 1,
    }
)

print("*** Performing inference ***")
response = cli.inference(params=params, serde="msgpack")

if response.status_code == 200:
    print(msgpack.unpackb(response.content))
else:
    print(response.status_code, response.content)
