import { Umzug, SequelizeStorage } from 'umzug';
import sequelize from './sequelize';

export const migrator = new Umzug({
    migrations: { glob: 'migrations/*.js' },
    context: sequelize.getQueryInterface(),
    storage: new SequelizeStorage({ sequelize }),
    logger: console,
})