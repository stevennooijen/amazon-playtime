# Playing with SageMaker

and MLflow?

### Data used

https://www.kaggle.com/mehdidag/black-friday/version/1

5 MB

538k x 12


### About Sagemaker

https://aws.amazon.com/getting-started/tutorials/build-train-deploy-machine-learning-model-sagemaker/

#### Common workflow

https://aws.amazon.com/blogs/machine-learning/how-to-use-common-workflows-on-amazon-sagemaker-notebook-instances/

#### Creating your own docker image

https://github.com/awslabs/amazon-sagemaker-examples/blob/master/advanced_functionality/scikit_bring_your_own/scikit_bring_your_own.ipynb

## Working with notebook instances

In theory, SageMaker notebook instances are great for data scientists in
the experimentation phase where the company doesn't like the scientists
to store data and code locally on their own machines.

However, there are some limitations that make it a bit tougher to work
 on SageMaker compared to working locally:
1. Instances are sealed off in such a way that you cannot ssh
into the machine, making it impossible to use IDE remote interpreters
2. It's not straightforward yet how to expose local processes on the
SageMaker instance to your own local machine (through proxies)
3. A little bit of extra effort is needed to set up Git, guarantee
persistent storage, and use virtual environments.


## Working with an IDE

Sadly it is [not possible](https://forums.aws.amazon.com/thread.jspa?messageID=865561&tstart=0)
to configure your (PyCharm) remote interpreter to work with SageMaker as
SageMaker blocks ssh tunnels.

This means you will have to work through pushing and pulling code with
Git.

Possibly, you could create a dummy data set locally that you use
for development and then run your code as a training/scoring job on
SageMaker if you want to access the real data.

## Lifecycle configurations

Lifecycle Configurations provide a mechanism to customize Notebook
Instances via shell scripts that are executed during the lifecycle of a
Notebook Instance (for example on start or create of an instance).

### Git on SageMaker

How to [set it up](https://docs.aws.amazon.com/sagemaker/latest/dg/nbi-git-repo.html).

One use cases for a lifecycle scripts is to initialize and configure
`gitconfig` scripts per user. See the `lifecycle-scripts/` folder for
an example.

### Virtual environments on SageMaker

Lifecycle scripts can be useful for creating and activating your own
virtual environments. See [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/notebook-lifecycle-config.html)
for a sample script on how to install a package in the Python3 env on
startup.

See other relevant example scripts
[here](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples).

### persistent storage

mount persistent disk

> eventueel ook mounten van s3 storage om persistent dingen op te slaan

if stopped, and then started again, do we keep the storage? > YES
i.e. do we need to commit end of day to keep our work? > No
Apparently persistent storage attached.
>> probably as long as the machine is not stopped?! what happens when
stopped and relaunched?

Question:
>> also, what happens if machine gets deleted? How do you easily set up
a new machine with the same settings?

possible solutions:
- check in in code to github end of day (and beginning of day pulling it)
    - can we do the git configuration automatically when firing up a new machine?
- mounting the sagemaker storage to an s3 bucket to make it persistent.


## Serving the MLflow UI on SageMaker

Serving is not as easy on SageMaker as is demonstrated in the
[quickstart guide](https://mlflow.org/docs/latest/quickstart.html#).

There are two options:

1. Run locally on SageMaker notebook instance through `mlflow ui` which
will serve the UI at `http://127.0.0.1:5000`. However, it's not
straightforward how to expose this process to you as a user. A solution
could be to:
    - Expose the process through a [jupter server proxy](https://github.com/jupyterhub/jupyter-server-proxy).
    This can be used for any process, like the Spark UI.
    - However, at the time of writing there is an open Github issue on this point:
    [Unable to run mlflow behind jupyter-server-proxy](https://github.com/mlflow/mlflow/issues/1120)

2. Run a [remote tracking server](https://mlflow.org/docs/latest/tracking.html#tracking-server)
where tracking results are stored centrally and from where the UI
is served such that results can be shared across a team.
