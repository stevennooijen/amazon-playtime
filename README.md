# Playing with SageMaker

Just some experiments to see what the tool is about, what it can and
what it cannot do.

### Data used

To play around we use a dataset from Kaggle called
[Black Friday](https://www.kaggle.com/mehdidag/black-friday/version/1).
It has a decent size of 5 MB, and includes 538k rows x 12 columns.

## About Sagemaker

Some helpful resources:

* A [tutorial](https://aws.amazon.com/getting-started/tutorials/build-train-deploy-machine-learning-model-sagemaker/)
on how to build, train, and deploy an ML model
* How to create your own docker image for
[custom ML models](https://github.com/awslabs/amazon-sagemaker-examples/blob/master/advanced_functionality/scikit_bring_your_own/scikit_bring_your_own.ipynb)
* Some [workflow best practices](https://aws.amazon.com/blogs/machine-learning/how-to-use-common-workflows-on-amazon-sagemaker-notebook-instances/)
on how to use Git and sync with S3 through lifecycle configurations

## Working with SageMaker notebook instances

In theory, SageMaker notebook instances are great for data scientists in
the experimentation phase where the company doesn't like the scientists
to store data and code locally on their own machines.

However, there are some limitations that make it a bit tougher to work
 on SageMaker compared to working locally:
1. Instances are sealed off in such a way that you cannot ssh
into the machine, making it very hard to use IDE remote interpreters
2. It's not straightforward yet how to expose local processes on the
SageMaker instance to your own local machine (through proxies)
3. A little bit of extra effort is needed to set up Git, guarantee
persistent storage, and use virtual environments.


### Working with an IDE

Sadly it is [not possible](https://forums.aws.amazon.com/thread.jspa?messageID=865561&tstart=0)
to configure your (PyCharm) remote interpreter to work with SageMaker
easily as SageMaker blocks ssh tunnels.

A hack around it is to set up a Virtual Private Cloud (VPC) with a
security group that contains inbound TCP rules that open port 22 to IP
addresses of your liking (for example of your organisation). you can
then add a SageMaker notebook instance to this security group, and
port 22 will now be open for incoming ssh traffic. You can then
configure the remote interpreter of your IDE.

Considering the above, it is likely easier to just share your code
between local and remote through pushing and pulling with Git. For
package development, it might be best to create a dummy data set
locally that you use for development (and creating unit tests!). If
the code looks good, you can then run it through a SageMaker training
or scoring job (instead of a notebook instance!) if you want to access
the real data.

### Lifecycle configurations

Lifecycle Configurations provide a mechanism to customize Notebook
Instances via shell scripts that are executed during the lifecycle of a
Notebook Instance (for example on start or create of an instance).

### Persistent storage

By default Amazon attaches a 5 GB ML persistent storage volume to the
instance. This can be increased up to 16 TB max. Read about it
[here](https://docs.aws.amazon.com/sagemaker/latest/dg/howitworks-create-ws.html)
* Only files and data saved within the `/home/ec2-user/SageMaker`
folder persist between notebook instance sessions.
* Each notebook instance's `/tmp` directory provides a minimum of
10 GB non-persistent storage in an instant store.

This means that between starting and stopping of the instance
your files are preserved based on the directory they are in.

For big files however, it might be recommended to store them on and
access them from S3. Alternatively, one can mount an
[Elastic File System](https://aws.amazon.com/blogs/machine-learning/mount-an-efs-file-system-to-an-amazon-sagemaker-notebook-with-lifecycle-configurations/)
for increased accessibility over Amazon S3. See the
`lifecycle-scripts/mount-efs.sh` script on how to do this in a lifecycle
configuration.

### Git on SageMaker

Connect your GitHub repository on AWS following
[these steps](https://aws.amazon.com/blogs/machine-learning/amazon-sagemaker-notebooks-now-support-git-integration-for-increased-persistence-collaboration-and-reproducibility/):
1. You are required to add the Git repository as a resource in your
Amazon SageMaker account.
2.  In case authentication is needed, you need to use the AWS Secrets
Manager to keep for example a personal access token.
3.  When the Git repository is created, you can associate it to your
notebook instances.

If successful, your project will be cloned in the persistent
`SageMaker/` folder on the instance.

If you don't want to add your Git repository as an AWS resource, or when
you don't like using the AWS Secrets Manager, you could of course set
up everything yourself using `.gitconfig` and `.git-credentials` files
that need to be copied to the not-persistent `.ssh/` folder every time
the resource is rebooted. You could configure this automatically,
using a lifecycle script. See `lifecycle-scripts/set-gitconfig.sh` for
an example.

### Virtual environments on SageMaker

Lifecycle scripts can be useful for creating and activating your own
virtual environments. See [documentation](https://docs.aws.amazon.com/sagemaker/latest/dg/notebook-lifecycle-config.html)
for a sample script on how to install a package in the Python3 env on
startup.

See other relevant example scripts
[here](https://github.com/aws-samples/amazon-sagemaker-notebook-instance-lifecycle-config-samples).


### Serving the MLflow UI on SageMaker

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
