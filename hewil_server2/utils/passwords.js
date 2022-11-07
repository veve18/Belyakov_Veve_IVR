var bcrypt = require("bcrypt");

const SALT_ROUNDS = 10;

const hashPassword = async (password) => {
	const salt = await bcrypt.genSalt(SALT_ROUNDS);
	const hash = await bcrypt.hash(password, salt);
	return { password: hash, salt };
};

const comparePassword = async (password, hash, salt) => {
	const result = await bcrypt.compare(password, hash);
	return result;
};

module.exports = {
	hashPassword,
	comparePassword,
};
