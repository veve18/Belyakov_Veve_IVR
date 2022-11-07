const { Sequelize, DataTypes } = require("sequelize");
const sequelize = require("../utils/database");
const charityOrganisation = require("./charityOrganisation");

const CharityPost = sequelize.define(
	"CharityPost",
	{
		title: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		description: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		charityOrganisationId: {
			type: DataTypes.INTEGER,
			allowNull: false,
		},
		requisites: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		image: {
			type: DataTypes.STRING,
			allowNull: false,
		},
		city: {
			type: DataTypes.STRING,
			allowNull: true,
		},
		isPhysical: {
			type: DataTypes.BOOLEAN,
			allowNull: false,
			defaultValue: false,
		},
	},
	{
		timestamps: true,
	}
);

CharityPost.sync({
	alter: true,
});

module.exports = CharityPost;
