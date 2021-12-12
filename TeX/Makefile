all:
	cd books && parallel context --nonstopmode --purgeall {} ::: c_*.tex

./context: install-context

clean-context:
	rm -rf ./context

install-context:
	mkdir -p ./context/ && cd ./context/ && \
	wget http://minimals.contextgarden.net/setup/first-setup.sh && \
	sh ./first-setup.sh --modules=all --context=latest --engine=luatex
