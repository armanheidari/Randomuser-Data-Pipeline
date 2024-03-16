import logging
import pathlib


dir_path = pathlib.Path(__file__).parent.parent


class Log():
    def __init__(self) -> None:
        '''
            Initializes two different loggers to log:
                - Info
                - Warnings and above
        '''
        error_formatter = logging.Formatter(
            fmt="%(asctime)s - %(levelname)s: %(message)s", datefmt="%Y-%m-%d %H:%M:%S")
        info_formatter = logging.Formatter(
            fmt="%(asctime)s: %(message)s", datefmt="%Y-%m-%d %H:%M:%S")

        error_handler = logging.FileHandler(dir_path / "log/error.log")
        info_handler = logging.FileHandler(dir_path / "log/info.log")

        error_handler.setFormatter(error_formatter)
        info_handler.setFormatter(info_formatter)

        self.error_logger = logging.getLogger('WarningsAndAbove')
        self.info_logger = logging.getLogger('Info')

        self.error_logger.setLevel(logging.WARNING)
        self.info_logger.setLevel(logging.INFO)

        self.error_logger.addHandler(error_handler)
        self.info_logger.addHandler(info_handler)

    def info(self, message: str) -> None:
        '''
            Log the message as `info` to the `info.log` file in the current directory
        '''
        self.info_logger.info(message + "\n" + "-" * 40)

    def warning(self, message: str) -> None:
        '''
            Log the message as `warning` to the `error.log` file in the current directory
        '''
        self.error_logger.warning(message + "\n" + "-" * 40, stacklevel=2)

    def error(self, message: str) -> None:
        '''
            Log the message as `error` to the `error.log` file in the current directory
        '''
        self.error_logger.error(message + "\n" + "-" * 40, stacklevel=2)

    def critical(self, message: str) -> None:
        '''
            Log the message as `critical` to the `error.log` file in the current directory
        '''
        self.error_logger.critical(message + "\n" + "-" * 40, stacklevel=2)


if __name__ == "__main__":
    logger = Log()
    logger.info("Info Test")
    logger.warning("Warning Test")
    logger.error("Error Test")
    logger.critical("Critical Test")
