#dockerfile for running on Azure machine learning
FROM mcr.microsoft.com/azureml/aifx/stable-ubuntu2004-cu113-py38-torch1110:biweekly.202301.1


# Install pip dependencies
RUN pip install 'ipykernel~=6.0' \
                'azureml-core==1.48.0' \
				'azureml-dataset-runtime==1.48.0' \
                'azureml-defaults==1.48.0' \
				'azure-ml==0.0.1' \
				'azure-ml-component==0.9.16.post2' \
                'azureml-mlflow==1.48.0' \
                'azureml-telemetry==1.48.0' \
		        'azureml-contrib-services==1.48.0' \
                'torch-tb-profiler~=0.4.0' \
				'py-spy==0.3.12' \
		        'debugpy~=1.6.3'

RUN pip install \
	azure-ai-ml==1.2.0 \
        azureml-inference-server-http~=0.7.0 \
        inference-schema~=1.4.2.1 \
        MarkupSafe==2.0.1 \
	    regex \
	    pybind11

# Inference requirements
COPY --from=mcr.microsoft.com/azureml/o16n-base/python-assets:20220607.v1 /artifacts /var/
RUN /var/requirements/install_system_requirements.sh && \
    cp /var/configuration/rsyslog.conf /etc/rsyslog.conf && \
    cp /var/configuration/nginx.conf /etc/nginx/sites-available/app && \
    ln -sf /etc/nginx/sites-available/app /etc/nginx/sites-enabled/app && \
    rm -f /etc/nginx/sites-enabled/default
ENV SVDIR=/var/runit
ENV WORKER_TIMEOUT=400
EXPOSE 5001 8883 8888

# support Deepspeed launcher requirement of passwordless ssh login
RUN apt-get update
RUN apt-get install -y openssh-server openssh-client

ADD . /Multimodal-Toolkit

RUN pip install -e /Multimodal-Toolkit