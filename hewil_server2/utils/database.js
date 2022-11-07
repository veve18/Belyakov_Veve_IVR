const { Sequelize } = require("sequelize");

const sequelize = new Sequelize(process.env.DATABASE_URL, {
	dialect: "mysql",
	dialectOptions: { ssl: {} },
});

module.exports = sequelize;
