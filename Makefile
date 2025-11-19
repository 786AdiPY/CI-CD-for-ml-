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
	python -c "from huggingface_hub import login; login(token='$(HF)', add_to_git_credential=True)"



push-hub:
	export HF_TOKEN=$(HF) && python -c "from huggingface_hub import HfApi; HfApi().upload_folder(repo_id='adi0697/Drug-classification', folder_path='./App', repo_type='space', commit_message='Sync App files')"
	export HF_TOKEN=$(HF) && python -c "from huggingface_hub import HfApi; HfApi().upload_folder(repo_id='adi0697/Drug-classification', folder_path='./Model', path_in_repo='/Model', repo_type='space', commit_message='Sync Model')"
	export HF_TOKEN=$(HF) && python -c "from huggingface_hub import HfApi; HfApi().upload_folder(repo_id='adi0697/Drug-classification', folder_path='./Results', path_in_repo='/Metrics', repo_type='space', commit_message='Sync Metrics')"

deploy: hf-login push-hub

all: install format train eval update-branch deploy
