import { ApolloClient, InMemoryCache } from "@apollo/client";

const uri = process.env.NODE_ENV === "production" ? "/api/graphql" : "/graphql";

export default new ApolloClient({
  uri,
  cache: new InMemoryCache(),
});
