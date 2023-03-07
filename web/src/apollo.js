import ApolloClient from 'apollo-boost';

const uri = process.env.NODE_ENV === 'production' ? '/api/graphql' : '/graphql';

export default new ApolloClient({
  uri,
});
