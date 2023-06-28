import { Stack, Skeleton } from "@chakra-ui/react";

const LoadingPlaceholder = () => (
  <Stack
    style={{
      padding: 5,
      display: "flex",
      flexDirection: "column",
    }}
  >
    <Skeleton height="20px" />
    <Skeleton height="20px" />
    <Skeleton height="20px" />
    <Skeleton height="20px" />
    <Skeleton height="20px" />
  </Stack>
);

export default LoadingPlaceholder;
