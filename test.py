import msgpack
import modelz

APIKey = "mzi-510edb7dff018ec70bc8e82671552dcc"
DeploymentKey = "mist-no7v6zho9zgwvzko"
timeout = 60 * 15

# create a modelz client
cli = modelz.ModelzClient(
    key=APIKey,
    deployment=DeploymentKey,
    host="https://mist-no7v6zho9zgwvzko.modelz.io/",
    timeout=timeout,
)

params = {
    "image_url": "https://raw.githubusercontent.com/apepkuss/mist/main/test/sample.png",
    "output_size": 512,
    "epsilon": 16,
    "steps": 100,
    "block_num": 1,
    "mode": 2,
    "rate": 1,
}


print("*** Performing inference ***")
response = cli.inference(params=params, serde="json")

if response.status_code == 200:
    print(msgpack.unpackb(response.content))
else:
    print(response.status_code, response.content)
