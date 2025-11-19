.PHONY: install
install:
	pip install --upgrade pip
	pip install --no-build-isolation -r requirements.txt

.PHONY: format
format:
	@echo "--- Formatting code ---"
	black .

.PHONY: train
train:
	@echo "--- Training model ---"
	python train.py

eval:
	echo "## Model Metrics" > report.md
	cat ./Results/metrics.txt >> report.md
	
	echo '\n## Confusion Matrix Plot' >> report.md
	echo '![Confusion Matrix](./Results/model_results.png)' >> report.md
	
	cml comment create report.md

update-branch:
	git config --global user.name $(ADI)
	git config --global user.email $(ADI_MAIL)
	git commit -am "Update with new results"
	git push --force origin HEAD:update

hf-login:
	pip install -U "huggingface_hub[cli]"
	git fetch origin update
	git checkout update
	# FIX: Use 'python -m huggingface_hub.cli' instead of just 'huggingface-cli'
	python -m huggingface_hub.cli login --token $(HF) --add-to-git-credentials



push-hub:
	huggingface-cli upload kingabzpro/Drug-Classification ./App --repo-type=space --commit-message="Sync App files"
	huggingface-cli upload kingabzpro/Drug-Classification ./Model /Model --repo-type=space --commit-message="Sync Model"
	huggingface-cli upload kingabzpro/Drug-Classification ./Results /Metrics --repo-type=space --commit-message="Sync Model"

deploy: hf-login push-hub

all: install format train eval update-branch deploy
