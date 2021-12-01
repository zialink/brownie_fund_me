from brownie import MockV3Aggregator, network, config, accounts

FORKED_LOCAL_ENVIRONMENT = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENT = ["development", "ganache-local"]
DECIMALS = 8
STARTING_PRICE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENT
        or network.show_active() in FORKED_LOCAL_ENVIRONMENT
    ):
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_keys"])


def get_price_feed_address():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENT:
        return config["networks"][network.show_active()]["eth_usd_price_feed"]
    else:
        if len(MockV3Aggregator) <= 0:
            MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": get_account()})
        return MockV3Aggregator[-1].address
