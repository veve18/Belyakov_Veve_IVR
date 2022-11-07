const { Sequelize, DataTypes } = require("sequelize");
const sequelize = require("../utils/database");

const CharityOrganisation = sequelize.define(
	"CharityOrganisation",
	{
		name: {
			type: DataTypes.STRING,
			allowNull: false,
			unique: true,
		},
		description: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		email: {
			type: DataTypes.STRING,
			allowNull: false,
			unique: true,
		},
		userpicURL: {
			type: DataTypes.STRING,
			allowNull: false,
			defaultValue: "https://i.imgur.com/1Q9ZQ9r.png",
		},
		phone: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		address: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		city: {
			type: DataTypes.STRING,
			allowNull: false,
			defaultValue: "Москва",
		},
		password: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		salt: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		isApproved: {
			type: DataTypes.BOOLEAN,
			allowNull: false,
			defaultValue: false,
		},
		contactLink: {
			type: DataTypes.STRING,
			allowNull: false,
			unique: true,
			defaultValue: "https://telegram.org",
		},
	},
	{
		timestamps: true,
	}
);

CharityOrganisation.sync({
	alter: true,
});

module.exports = CharityOrganisation;
