.PHONY: dev lint complex coverage pre-commit yapf sort deploy destroy



dev:
	pipenv install --dev

lint:
	@echo "Running flake8"
	flake8 service/* tests/*

coverage:
	pytest --cov

complex:
	@echo "Running Radon"
	radon cc -e 'tests/*,cdk.out/*' .
	@echo "Running xenon"
	xenon --max-absolute B --max-modules A --max-average A -e 'tests/*,.venv/*,cdk.out/*' .

sort:
	isort ${PWD}

pre-commit:
	pre-commit run -a

pr: yapf sort pre-commit complex lint coverage

yapf:
	yapf -i -vv --style=./.style --exclude=.venv --exclude=.build --exclude=cdk.out --exclude=.git  -r .

deploy:
	mkdir -p .build/lambdas ; cp -r service .build/lambdas
	mkdir -p .build/common_layer ; pipenv lock -r > .build/common_layer/requirements.txt

	cdk deploy --app="python3 ${PWD}/cdk/aws_lambda_handler_cookbook/app.py" -require-approval=True

destroy:
	cdk destroy --app="python3 ${PWD}/cdk/aws_lambda_handler_cookbook/app.py" -require-approval=True
